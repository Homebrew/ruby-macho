module MachO
	class File
		attr_reader :header, :load_commands

		def initialize(file)
			@raw_data = open(file, "rb") { |f| f.read }
			@header = get_mach_header
			# @load_commands = get_load_commands
			# @segment_commands = get_segment_commands
		end

		def executable?
			header[:filetype] == MH_EXECUTE
		end

		def dylib?
			header[:filetype] == MH_DYLIB
		end

		def bundle?
			header[:filetype] == MH_BUNDLE
		end

		def magic
			MH_MAGICS[header[:magic]]
		end

		def filetype
			MH_FILETYPES[header[:filetype]]
		end

		def cputype
			CPU_TYPES[header[:cputype]]
		end

		def cpusubtype
			CPU_SUBTYPES[header[:cpusubtype]]
		end

		def ncmds
			header[:ncmds]
		end

		def sizeofcmds
			header[:sizeofcmds]
		end

		def flags
			header[:flags]
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
				raise FiletypeError(filetype)
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
	end
end
