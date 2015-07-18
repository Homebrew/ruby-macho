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

	class CPUTypeError < MachOError
		def initialize(num)
			super "Unrecognized CPU type: 0x#{"%02x" % num}"
		end
	end

	class CPUSubtypeError < MachOError
		def initialize(num)
			super "Unrecognized CPU sub-type: 0x#{"%02x" % num}"
		end
	end

	# raised when a mach-o file's filetype field is unknown
	class FiletypeError < MachOError
		def initialize(num)
			super "Unrecognized Mach-O filetype code: 0x#{"%02x" % num}"
		end
	end

	# raised when an unknown load command is encountered
	class LoadCommandError < MachOError
		def initialize(num)
			super "Unrecognized Mach-O load command: 0x#{"%02x" % num}"
		end
	end
end
