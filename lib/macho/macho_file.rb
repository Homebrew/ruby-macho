module MachO
	class MachOFile
		attr_reader :header, :load_commands

		def self.new_from_bin(bin)
			instance = allocate
			instance.initialize_from_bin(bin)

			instance
		end

		def initialize(filename)
			raise ArgumentError.new("filename must be a String") unless filename.is_a? String

			@filename = filename
			@raw_data = open(@filename, "rb") { |f| f.read }
			@header = get_mach_header
			@load_commands = get_load_commands
		end

		def initialize_from_bin(bin)
			@filename = nil
			@raw_data = bin
			@header = get_mach_header
			@load_commands = get_load_commands
		end

		def magic32?
			Utils.magic32?(header[:magic])
		end

		def magic64?
			Utils.magic64?(header[:magic])
		end

		# is the file executable?
		def executable?
			header[:filetype] == MH_EXECUTE
		end

		# is the file a dynamically bound shared object?
		def dylib?
			header[:filetype] == MH_DYLIB
		end

		# is the file a dynamically bound bundle?
		def bundle?
			header[:filetype] == MH_BUNDLE
		end

		def magic
			header[:magic]
		end

		# string representation of the header's magic bytes
		def magic_string
			MH_MAGICS[header[:magic]]
		end

		# string representation of the header's filetype field
		def filetype
			MH_FILETYPES[header[:filetype]]
		end

		# string representation of the header's cputype field
		def cputype
			CPU_TYPES[header[:cputype]]
		end

		# string representation of the header's cpusubtype field
		def cpusubtype
			CPU_SUBTYPES[header[:cpusubtype]]
		end

		# number of load commands in the header
		def ncmds
			header[:ncmds]
		end

		# size of all load commands
		def sizeofcmds
			header[:sizeofcmds]
		end

		# various execution flags
		def flags
			header[:flags]
		end

		# get load commands by name
		def command(name)
			load_commands.select { |lc| lc.to_s == name }
		end

		alias :[] :command

		# get all segment commands
		def segments
			if magic32?
				command("LC_SEGMENT")
			else
				command("LC_SEGMENT_64")
			end
		end

		# get the file's dylib id, if it is a dylib
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

		def dylib_id=(new_id)
			if !new_id.is_a?(String)
				raise ArgumentError.new("argument must be a String")
			end

			if !dylib?
				return nil
			end

			if magic32?
				cmd_round = 4
			else
				cmd_round = 8
			end

			new_sizeofcmds = header[:sizeofcmds]
			dylib_id_cmd = command('LC_ID_DYLIB').first
			old_id = dylib_id
			new_id = new_id.dup

			new_pad = Utils.round(new_id.size, cmd_round) - new_id.size
			old_pad = Utils.round(old_id.size, cmd_round) - old_id.size

			# pad the old and new IDs with null bytes to meet command bounds
			old_id << "\x00" * old_pad
			new_id << "\x00" * new_pad

			# calculate the new size of the DylibCommand and sizeofcmds in MH
			new_size = DylibCommand.bytesize + new_id.size
			new_sizeofcmds += new_size - dylib_id_cmd.cmdsize

			# calculate the low file offset (offset to first section data)
			low_fileoff = 2**64 # ULLONGMAX

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
			@raw_data[dylib_id_cmd.offset + 4, 4] = [new_size].pack("V")

			# delete the old id
			@raw_data.slice!(dylib_id_cmd.offset + dylib_id_cmd.name...dylib_id_cmd.offset + dylib_id_cmd.class.bytesize + old_id.size)

			# insert the new id
			@raw_data.insert(dylib_id_cmd.offset + dylib_id_cmd.name, new_id)

			# pad/unpad after new_sizeofcmds until offsets are corrected
			null_pad = old_id.size - new_id.size

			if null_pad < 0
				@raw_data.slice!(new_sizeofcmds + header.bytesize, null_pad.abs)
			else
				@raw_data.insert(new_sizeofcmds + header.bytesize, "\x00" * null_pad)
			end

			# synchronize fields with the raw data
			header = get_mach_header
			load_commands = get_load_commands
		end

		# get a list of dylib paths linked to this file
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

		# get all sections in a segment by name
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

		def write(filename)
			File.open(filename, "wb") { |f| f.write(@raw_data) }
		end

		def write!
			if @filename.nil?
				raise MachOError.new("cannot write to a default file when initialized from a binary string")
			else
				File.open(@filename, "wb") { |f| f.write(@raw_data) }
			end
		end

		private

		def get_mach_header
			magic = get_magic
			cputype = get_cputype
			cpusubtype = get_cpusubtype
			filetype = get_filetype
			ncmds = get_ncmds
			sizeofcmds = get_sizeofcmds
			flags = get_flags
			
			if Utils.magic32?(magic)
				MachHeader.new(magic, cputype, cpusubtype, filetype, ncmds, sizeofcmds, flags)
			else
				# the reserved field is...reserved, so just fill it with 0
				MachHeader64.new(magic, cputype, cpusubtype, filetype, ncmds, sizeofcmds, flags, 0)
			end
		end

		def get_magic
			magic = @raw_data[0..3].unpack("N").first

			if !Utils.magic?(magic)
				raise MagicError.new(magic)
			end
			
			# TODO: support fat (universal) binaries
			if Utils.fat_magic?(magic)
				raise FatBinaryError.new(magic)
			end

			magic
		end

		def get_cputype
			cputype = @raw_data[4..7].unpack("V").first

			if !CPU_TYPES.keys.include?(cputype)
				raise CPUTypeError.new(cputype)
			end

			cputype
		end

		def get_cpusubtype
			cpusubtype = @raw_data[8..11].unpack("V").first

			# this mask isn't documented!
			cpusubtype &= ~CPU_SUBTYPE_LIB64

			if !CPU_SUBTYPES.keys.include?(cpusubtype)
				raise CPUSubtypeError.new(cpusubtype)
			end

			cpusubtype
		end

		def get_filetype
			filetype = @raw_data[12..15].unpack("V").first

			if !MH_FILETYPES.keys.include?(filetype)
				raise FiletypeError.new(filetype)
			end

			filetype
		end

		def get_ncmds
			ncmds = @raw_data[16..19].unpack("V").first

			ncmds
		end

		def get_sizeofcmds
			sizeofcmds = @raw_data[20..23].unpack("V").first

			sizeofcmds
		end

		def get_flags
			flags = @raw_data[24..27].unpack("V").first

			flags
		end

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
				klass = Object.const_get "MachO::#{LC_STRUCTURES[cmd]}"
				command = klass.new_from_bin(offset, @raw_data.slice(offset, klass.bytesize))

				load_commands << command
				offset += command.cmdsize
			end

			load_commands
		end

		def set_sizeofcmds(size)
			new_size = [size].pack("V")
			@raw_data[20..23] = new_size
		end
	end
end
