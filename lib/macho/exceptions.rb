module MachO
	# generic toplevel error
	class MachOError < RuntimeError
	end

	# raised when a file's magic bytes are not valid mach-o magic
	class MagicError < MachOError
		def initialize(num)
			super "Unrecognized Mach-O magic: 0x#{"%02x" % num}"
		end
	end

	# raised when a file's magic bytes are those of a fat binary
	class FatBinaryError < MachOError
		def initialize(num)
			super "Unsupported fat binary (magic 0x#{"%02x" % num})"
		end
	end

	# raised when a mach-o file's filetype field is unknown
	class FiletypeError < MachOError
		def initialize(num)
			super "Unrecognized Mach-O filetype code: 0x#{"%02x" % num}"
		end
	end
end
