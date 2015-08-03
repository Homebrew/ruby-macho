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

	class FatBinaryError < MachOError
		def initialize
			super "Fat binaries must be loaded with MachO::FatFile"
		end
	end

	class MachOBinaryError < MachOError
		def initialize
			super "Normal binaries must be loaded with MachO::MachOFile"
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

	# raised when load commands are too large to fit in the current file
	class HeaderPadError < MachOError
		def initialize(filename)
			super "Updated load commands do not fit in the header of " +
			"#{filename}. #{filename} needs to be relinked, possibly with " +
			"-headerpad or -headerpad_max_install_names"
		end
	end
end
