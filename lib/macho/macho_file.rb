module MachO
	# Represents a Mach-O file, which contains a header and load commands
	# as well as binary executable instructions. Mach-O binaries are
	# architecture specific.
	# @see https://en.wikipedia.org/wiki/Mach-O
	# @see MachO::FatFile
	class MachOFile
		# @return [MachO::MachHeader] if the Mach-O is 32-bit
		# @return [MachO::MachHeader64] if the Mach-O is 64-bit
		attr_reader :header

		# @return [Array<MachO::LoadCommand>] an array of the file's load commands
		attr_reader :load_commands

		# Creates a new MachOFile instance from a binary string.
		# @param bin [String] a binary string containing raw Mach-O data
		# @return [MachO::MachOFile] a new MachOFile
		def self.new_from_bin(bin)
			instance = allocate
			instance.initialize_from_bin(bin)

			instance
		end

		# Creates a new FatFile from the given filename.
		# @param filename [String] the Mach-O file to load from
		# @todo document all the exceptions propagated here
		def initialize(filename)
			raise ArgumentError.new("filename must be a String") unless filename.is_a? String

			@filename = filename
			@raw_data = open(@filename, "rb") { |f| f.read }
			@header = get_mach_header
			@load_commands = get_load_commands
		end

		# @private
		def initialize_from_bin(bin)
			@filename = nil
			@raw_data = bin
			@header = get_mach_header
			@load_commands = get_load_commands
		end

		# The file's raw Mach-O data.
		# @return [String] the raw Mach-O data
		def serialize
			@raw_data
		end

		# @return [Boolean] true if the Mach-O has 32-bit magic, false otherwise
		def magic32?
			MachO.magic32?(header[:magic])
		end

		# @return [Boolean] true if the Mach-O has 64-bit magic, false otherwise
		def magic64?
			MachO.magic64?(header[:magic])
		end

		# @return [Boolean] true if the Mach-O is of type `MH_EXECUTE`, false otherwise
		def executable?
			header[:filetype] == MH_EXECUTE
		end

		# @return [Boolean] true if the Mach-O is of type `MH_DYLIB`, false otherwise
		def dylib?
			header[:filetype] == MH_DYLIB
		end

		# @return [Boolean] true if the Mach-O is of type `MH_BUNDLE`, false otherwise
		def bundle?
			header[:filetype] == MH_BUNDLE
		end

		# @return [Fixnum] the Mach-O's magic number
		def magic
			header[:magic]
		end

		# @return [String] a string representation of the Mach-O's magic number
		def magic_string
			MH_MAGICS[header[:magic]]
		end

		# @return [String] a string representation of the Mach-O's filetype
		def filetype
			MH_FILETYPES[header[:filetype]]
		end

		# @return [String] a string representation of the Mach-O's CPU type
		def cputype
			CPU_TYPES[header[:cputype]]
		end

		# @return [String] a string representation of the Mach-O's CPU subtype
		def cpusubtype
			CPU_SUBTYPES[header[:cpusubtype]]
		end

		# @return [Fixnum] the number of load commands in the Mach-O's header
		def ncmds
			header[:ncmds]
		end

		# @return [Fixnum] the size of all load commands, in bytes
		def sizeofcmds
			header[:sizeofcmds]
		end

		# @return [Fixnum] execution flags set by the linker
		def flags
			header[:flags]
		end

		# All load commands of a given name.
		# @example
		#  file.command("LC_LOAD_DYLIB")
		#  file["LC_LOAD_DYLIB"]
		# @return [Array<MachO::LoadCommand>] an array of LoadCommands corresponding to `name`
		def command(name)
			load_commands.select { |lc| lc.to_s == name }
		end

		alias :[] :command

		# All segment load commands in the Mach-O.
		# @return [Array<MachO::SegmentCommand>] if the Mach-O is 32-bit
		# @return [Array<MachO::SegmentCommand64>] if the Mach-O is 64-bit
		def segments
			if magic32?
				command("LC_SEGMENT")
			else
				command("LC_SEGMENT_64")
			end
		end

		# The Mach-O's dylib ID, or `nil` if not a dylib.
		# @example
		#  file.dylib_id # => 'libBar.dylib'
		# @return [String] the Mach-O's dylib ID
		def dylib_id
			if !dylib?
				return nil
			end

			dylib_id_cmd = command('LC_ID_DYLIB').first

			cmdsize = dylib_id_cmd.cmdsize
			offset = dylib_id_cmd.offset
			stroffset = dylib_id_cmd.name

			dylib_id = @raw_data.slice(offset + stroffset...offset + cmdsize).unpack("Z*").first

			dylib_id.delete("\x00")
		end

		# Changes the Mach-O's dylib ID to `new_id`. Does nothing if not a dylib.
		# @example
		#  file.dylib_id = "libFoo.dylib"
		# @param new_id [String] the dylib's new ID
		# @return [void]
		def dylib_id=(new_id)
			if !new_id.is_a?(String)
				raise ArgumentError.new("argument must be a String")
			end

			if !dylib?
				return nil
			end

			dylib_cmd = command('LC_ID_DYLIB').first
			old_id = dylib_id

			set_name_in_dylib(dylib_cmd, old_id, new_id)
		end

		# All shared libraries linked to the Mach-O.
		# @return [Array<String>] an array of all shared libraries
		def linked_dylibs
			dylibs = []
			dylib_cmds = command('LC_LOAD_DYLIB')

			dylib_cmds.each do |dylib_cmd|
				cmdsize = dylib_cmd.cmdsize
				offset = dylib_cmd.offset
				stroffset = dylib_cmd.name

				dylib = @raw_data.slice(offset + stroffset...offset + cmdsize).unpack("Z*").first

				dylibs << dylib
			end

			dylibs
		end

		# Changes the shared library `old_name` to `new_name`
		# @example
		#  file.change_install_name("/usr/lib/libWhatever.dylib", "/usr/local/lib/libWhatever2.dylib")
		# @param old_name [String] the shared library's old name
		# @param new_name [String] the shared library's new name
		# @return [void]
		def change_install_name(old_name, new_name)
			idx = linked_dylibs.index(old_name)
			raise DylibUnknownError.new(old_name) if idx.nil?

			# this is a bit of a hack - since there is a 1-1 ordered association
			# between linked_dylibs and command('LC_LOAD_DYLIB'), we can use
			# their indices interchangeably to avoid having to loop.
			dylib_cmd = command('LC_LOAD_DYLIB')[idx]

			set_name_in_dylib(dylib_cmd, old_name, new_name)
		end

		alias :change_dylib :change_install_name

		# All sections of the segment `segment`.
		# @return [Array<MachO::Section>] if the Mach-O is 32-bit
		# @return [Array<MachO::Section64>] if the Mach-O is 64-bit
		def sections(segment)
			sections = []

			if !segment.is_a?(SegmentCommand) && !segment.is_a?(SegmentCommand64)
				raise ArgumentError.new("not a valid segment")
			end

			if segment.nsects.zero?
				return sections
			end

			offset = segment.offset + segment.class.bytesize

			segment.nsects.times do
				if segment.is_a? SegmentCommand
					sections << Section.new_from_bin(@raw_data.slice(offset, Section.bytesize))
					offset += Section.bytesize
				else
					sections << Section64.new_from_bin(@raw_data.slice(offset, Section64.bytesize))
					offset += Section64.bytesize
				end
			end

			sections
		end

		# Write all Mach-O data to the given filename.
		# @param filename [String] the file to write to
		# @return [void]
		def write(filename)
			File.open(filename, "wb") { |f| f.write(@raw_data) }
		end

		# Write all Mach-O data to the file used to initialize the instance.
		# @raise [MachOError] if the instance was created from a binary string
		# @return [void]
		# @note Overwrites all data in the file!
		def write!
			if @filename.nil?
				raise MachOError.new("cannot write to a default file when initialized from a binary string")
			else
				File.open(@filename, "wb") { |f| f.write(@raw_data) }
			end
		end

		private

		# The file's Mach-O header structure.
		# @return [MachO::MachHeader] if the Mach-O is 32-bit
		# @return [MachO::MachHeader64] if the Mach-O is 64-bit
		# @private
		def get_mach_header
			magic = get_magic
			cputype = get_cputype
			cpusubtype = get_cpusubtype
			filetype = get_filetype
			ncmds = get_ncmds
			sizeofcmds = get_sizeofcmds
			flags = get_flags
			
			if MachO.magic32?(magic)
				MachHeader.new(magic, cputype, cpusubtype, filetype, ncmds, sizeofcmds, flags)
			else
				# the reserved field is...reserved, so just fill it with 0
				MachHeader64.new(magic, cputype, cpusubtype, filetype, ncmds, sizeofcmds, flags, 0)
			end
		end

		# The file's magic number.
		# @return [Fixnum] the magic
		# @raise [MachO::MagicError] if the magic is not valid Mach-O magic
		# @raise [MachO::FatBinaryError] if the magic is for a Fat file
		# @private
		def get_magic
			magic = @raw_data[0..3].unpack("N").first

			if !MachO.magic?(magic)
				raise MagicError.new(magic)
			end
			
			if MachO.fat_magic?(magic)
				raise FatBinaryError.new
			end

			magic
		end

		# The file's CPU type.
		# @return [Fixnum] the CPU type
		# @raise [MachO::CPUTypeError] if the CPU type is unknown
		# @private
		def get_cputype
			cputype = @raw_data[4..7].unpack("V").first

			if !CPU_TYPES.has_key?(cputype)
				raise CPUTypeError.new(cputype)
			end

			cputype
		end

		# The file's CPU subtype.
		# @return [Fixnum] the CPU subtype
		# @raise [MachO::CPUSubtypeError] if the CPU subtype is unknown
		# @private
		def get_cpusubtype
			cpusubtype = @raw_data[8..11].unpack("V").first

			# this mask isn't documented!
			cpusubtype &= ~CPU_SUBTYPE_LIB64

			if !CPU_SUBTYPES.has_key?(cpusubtype)
				raise CPUSubtypeError.new(cpusubtype)
			end

			cpusubtype
		end

		# The file's type.
		# @return [Fixnum] the file type
		# @raise [MachO::FiletypeError] if the file type is unknown
		# @private
		def get_filetype
			filetype = @raw_data[12..15].unpack("V").first

			if !MH_FILETYPES.has_key?(filetype)
				raise FiletypeError.new(filetype)
			end

			filetype
		end

		# The number of load commands in the file.
		# @return [Fixnum] the number of load commands
		# @private
		def get_ncmds
			ncmds = @raw_data[16..19].unpack("V").first

			ncmds
		end

		# The size of all load commands, in bytes.
		# return [Fixnum] the size of all load commands
		# @private
		def get_sizeofcmds
			sizeofcmds = @raw_data[20..23].unpack("V").first

			sizeofcmds
		end

		# The Mach-O header's flags.
		# @return [Fixnum] the flags
		# @private
		def get_flags
			flags = @raw_data[24..27].unpack("V").first

			flags
		end

		# All load commands in the file.
		# @return [Array<MachO::LoadCommand>] an array of load commands
		# @raise [MachO::LoadCommandError] if an unknown load command is encountered
		# @private
		def get_load_commands
			offset = header.bytesize
			load_commands = []

			header[:ncmds].times do
				cmd = @raw_data.slice(offset, 4).unpack("V").first

				if !LC_STRUCTURES.has_key?(cmd)
					raise LoadCommandError.new(cmd)
				end

				# why do I do this? i don't like declaring constants below
				# classes, and i need them to resolve...
				klass = MachO.const_get "#{LC_STRUCTURES[cmd]}"
				command = klass.new_from_bin(offset, @raw_data.slice(offset, klass.bytesize))

				load_commands << command
				offset += command.cmdsize
			end

			load_commands
		end

		# Updates the size of all load commands in the raw data.
		# @param size [Fixnum] the new size, in bytes
		# @return [void]
		# @private
		def set_sizeofcmds(size)
			new_size = [size].pack("V")
			@raw_data[20..23] = new_size
		end

		# Updates the `name` field in a DylibCommand, regardless of load command type
		# @param dylib_cmd [MachO::DylibCommand] the dylib command
		# @param old_name [String] the old dylib name
		# @param new_name [String] the new dylib name
		# @return [void]
		# @private
		def set_name_in_dylib(dylib_cmd, old_name, new_name)
			if magic32?
				cmd_round = 4
			else
				cmd_round = 8
			end

			new_sizeofcmds = header[:sizeofcmds]
			old_name = old_name.dup
			new_name = new_name.dup

			old_pad = MachO.round(old_name.size, cmd_round) - old_name.size
			new_pad = MachO.round(new_name.size, cmd_round) - new_name.size

			# pad the old and new IDs with null bytes to meet command bounds
			old_name << "\x00" * old_pad
			new_name << "\x00" * new_pad

			# calculate the new size of the DylibCommand and sizeofcmds in MH
			new_size = DylibCommand.bytesize + new_name.size
			new_sizeofcmds += new_size - dylib_cmd.cmdsize

			low_fileoff = 2**64 # ULLONGMAX

			# calculate the low file offset (offset to first section data)
			segments.each do |seg|
				sections(seg).each do |sect|
					if sect.size != 0 && !sect.flag?(S_ZEROFILL) &&
							!sect.flag?(S_THREAD_LOCAL_ZEROFILL) &&
							sect.offset < low_fileoff

						low_fileoff = sect.offset
					end
				end
			end

			if new_sizeofcmds + header.bytesize > low_fileoff
				raise HeaderPadError.new(@filename)
			end

			# update sizeofcmds in mach_header
			set_sizeofcmds(new_sizeofcmds)

			# update cmdsize in the dylib_command
			@raw_data[dylib_cmd.offset + 4, 4] = [new_size].pack("V")

			# delete the old name
			@raw_data.slice!(dylib_cmd.offset + dylib_cmd.name...dylib_cmd.offset + dylib_cmd.class.bytesize + old_name.size)

			# insert the new id
			@raw_data.insert(dylib_cmd.offset + dylib_cmd.name, new_name)

			# pad/unpad after new_sizeofcmds until offsets are corrected
			null_pad = old_name.size - new_name.size

			if null_pad < 0
				@raw_data.slice!(new_sizeofcmds + header.bytesize, null_pad.abs)
			else
				@raw_data.insert(new_sizeofcmds + header.bytesize, "\x00" * null_pad)
			end

			# synchronize fields with the raw data
			@header = get_mach_header
			@load_commands = get_load_commands
		end
	end
end
