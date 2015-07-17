module MachO
	class File
		attr_reader :header, :load_commands

		def initialize(file)
			@raw_data = open(file, "rb") { |f| f.read }.unpack("C*")
			@header = get_mach_header
			# @load_commands = get_load_commands
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
			
			if magic == MH_MAGIC || magic == MH_CIGAM
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

			# if we're given a fat binary, we need to get its real magic first
			if magic == FAT_MAGIC || magic == FAT_CIGAM
				# NOTE: this is probably the Wrong Thing.
				@raw_data.shift(4096)
				magic = @raw_data[0..3].map { |b| b.to_s(16) }.join.hex
			end

			magic
		end

		# TODO: unstub
		def get_cputype
			0
		end

		# TODO: unstub
		def get_cpusubtype
			0
		end

		# TODO: unstub
		def get_filetype
			0
		end

		# TODO: unstub
		def get_ncmds
			0
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
