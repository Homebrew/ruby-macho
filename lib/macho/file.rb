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

		# get the file's dylib id, if it is a dylib
		def dylib_id
			if !dylib?
				return nil
			end

			offset = header.bytesize

			load_commands.each do |lc|
				break if lc[:cmd] == LC_ID_DYLIB
				offset += lc[:cmdsize]
			end

			cmd, cmdsize = @raw_data.slice(offset, 8).unpack("VV")

			if !cmd == LC_ID_DYLIB
				return nil
			end

			stroffset = @raw_data.slice(offset + 8, 4).unpack("V").first
			dylib_id = @raw_data.slice(offset + stroffset, offset + cmdsize - 1).unpack("Z*").first

			dylib_id
		end

		# TODO: unstub
		def dylib_id=(new_id)
			0
		end

		def write(filename)
			File.open(filename, "wb") { |f| f.write(@raw_data) }
		end

		def write!
			File.open(@filename, "wb") { |f| f.write(@raw_data) }
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
				raise "bad cpu type: #{cputype}"
			end

			cputype
		end

		def get_cpusubtype
			cpusubtype = @raw_data[8..11].unpack("V").first

			cpusubtype
		end

		def get_filetype
			filetype = @raw_data[12..15].unpack("V").first

			if filetype < 0x1 || filetype > 0xb
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
				cmd, cmdsize = @raw_data.slice(offset, 8).unpack("VV")

				if !LOAD_COMMANDS.keys.include?(cmd)
					raise LoadCommandError.new(cmd)
				end

				load_commands << LoadCommand.new(cmd, cmdsize)
				offset += cmdsize
			end

			load_commands
		end
	end
end
