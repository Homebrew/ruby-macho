module MachO
	class File
		attr_reader :header, :load_commands

		def initialize(file)
			@raw_data = open(file, "rb") { |f| f.read }.unpack("C*")
			@header = get_mach_header
			# @load_commands = get_load_commands
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
			header[:cpusubtype]
		end

		def ncmds
			header[:ncmds]
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
				# the reserved field is a mystery, so just fill it with 0
				header = MachHeader64.new(magic, cputype, cpusubtype, filetype, ncmds, sizeofcmds, flags, 0)
			end
		end

		def get_magic
			# TODO: find a better way to join 4 ints as hex, not dec
			magic = @raw_data[0..3].map { |b| b.to_s(16) }.join.hex

			if !MachO.magic?(magic)
				# TODO: custom exceptions
				raise "bad magic"
			end

			
			# we have to do extra work to get offsets for fat binaries
			if MachO.fat_magic?(magic)
				raise "fat binary, not supported yet"
			end
			# # if we're given a fat binary, we need to get its real magic first
			# if magic == FAT_MAGIC || magic == FAT_CIGAM
			# 	# NOTE: this is probably the Wrong Thing.
			# 	@raw_data.shift(4096)
			# 	magic = @raw_data[0..3].map { |b| b.to_s(16) }.join.hex
			# end

			magic
		end

		def get_cputype
			cputype = @raw_data[4..7].map { |b| "%02x" % b }.join.hex

			if !CPU_TYPES.keys.include?(cputype)
				raise "bad cpu type: #{cputype}"
			end

			cputype
		end

		# TODO: unstub
		def get_cpusubtype
			cpusubtype = @raw_data[8..11].map { |b| "%02x" % b }.join

			# puts cpusubtype

			# TODO: decode cpusubtype
			cpusubtype
		end

		def get_filetype
			# NOTE: the filetype field is actually 4 bytes [12..15], but
			# there aren't any filetype constants above 0xb in loader.h
			filetype = @raw_data[12].to_s(16).hex

			if filetype < 0x1 || filetype > 0xb
				raise "bad filetype"
			end

			filetype
		end

		# TODO: unstub
		def get_ncmds
			# NOTE: the ncmds field is actually 4 bytes, so this won't work
			# if a binary has more than 255 load commands (!!)
			ncmds = @raw_data[16]

			ncmds
		end

		# TODO: unstub
		def get_sizeofcmds
			0
		end

		# TODO: unstub
		def get_flags
			0
		end
	end
end
