module MachO
	class MachOFile
		attr_reader :header, :load_commands

		def initialize(filename)
			@filename = filename
			@raw_data = open(@filename, "rb") { |f| f.read }
			@header = get_mach_header
			@load_commands = get_load_commands
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

		# string representation of the header's magic bytes
		def magic
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

			dylib_id
		end

		# TODO: unstub
		def dylib_id=(new_id)
			if !new_id.is_a?(String)
				raise ArgumentError.new("argument must be a String")
			end

			if !dylib?
				return nil
			end

			dylib_id_cmd = command('LC_ID_DYLIB').first

			cmdsize = dylib_id_cmd.cmdsize
			offset = dylib_id_cmd.offset
			stroffset = dylib_id_cmd.name

			old_id = @raw_data.slice(offset + stroffset...offset + cmdsize).unpack("Z*").first

			if old_id.size > new_id.size
				delta = old_id.size - new_id.size
				# steps:
				# use delta to pad new_id with null bytes to preserve LC bounds
				# > update delta to reflect new size!
				# update name field to the new 'name' (really size)
				# delete the old_id from @raw_data
				# insert the new_id into @raw_data
				# add any additional null bytes after header[:sizeofcmds]-delta
				raise "unimplemented"
			elsif old_id.size < new_id.size
				# padding needs to be removed
				raise "unimplemented"
			else
				# no padding. hooray!
				@raw_data[offset + stroffset, old_id.size] = new_id
				# sync fields
			end
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
			File.open(@filename, "wb") { |f| f.write(@raw_data) }
		end

		#######
		private

		def get_mach_header
			magic = get_magic
			cputype = get_cputype
			cpusubtype = get_cpusubtype
			filetype = get_filetype
			ncmds = get_ncmds
			sizeofcmds = get_sizeofcmds
			flags = get_flags
			
			if MachO.magic32?(magic)
				header = MachHeader.new(magic, cputype, cpusubtype, filetype, ncmds, sizeofcmds, flags)
			else
				# the reserved field is reserved, so just fill it with 0
				header = MachHeader64.new(magic, cputype, cpusubtype, filetype, ncmds, sizeofcmds, flags, 0)
			end
		end

		def get_magic
			magic = @raw_data[0..3].unpack("N").first

			if !MachO.magic?(magic)
				raise MagicError.new(magic)
			end

			
			# TODO: support fat (universal) binaries
			if MachO.fat_magic?(magic)
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

		# TODO: parse flags, maybe?
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

				klass = LC_STRUCTURES[cmd]
				command = klass.new_from_bin(offset, @raw_data.slice(offset, klass.bytesize))

				load_commands << command
				offset += command.cmdsize
			end

			load_commands
		end
	end
end
