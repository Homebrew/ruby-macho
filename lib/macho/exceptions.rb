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

	# raised when a fat binary is loaded with MachOFile
	class FatBinaryError < MachOError
		def initialize
			super "Fat binaries must be loaded with MachO::FatFile"
		end
	end

	# raised when a mach-o is loaded with FatFile
	class MachOBinaryError < MachOError
		def initialize
			super "Normal binaries must be loaded with MachO::MachOFile"
		end
	end

	# raised when the CPU type is unknown
	class CPUTypeError < MachOError
		def initialize(num)
			super "Unrecognized CPU type: 0x#{"%02x" % num}"
		end
	end

	# raised when the CPU subtype is unknown
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

	# raised when attempting to change a dylib name that doesn't exist
	class DylibUnknownError < MachOError
		def initialize(dylib)
			super "No such dylib name: #{dylib}"
		end
	end
end
