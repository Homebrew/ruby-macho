module MachO
  # A generic Mach-O error in execution.
  class MachOError < RuntimeError
  end

  # Raised when a file's magic bytes are not valid Mach-O magic.
  class MagicError < MachOError
    # @param num [Fixnum, nil] the unknown number or nil if no number was read
    def initialize(num)
      if num
        super "Unrecognized Mach-O magic: 0x#{"%02x" % num}"
      else
        super "Unrecognized Mach-O magic: file too short"
      end
    end
  end

  # Raised when a fat binary is loaded with MachOFile.
  class FatBinaryError < MachOError
    def initialize
      super "Fat binaries must be loaded with MachO::FatFile"
    end
  end

  # Raised when a Mach-O is loaded with FatFile.
  class MachOBinaryError < MachOError
    def initialize
      super "Normal binaries must be loaded with MachO::MachOFile"
    end
  end

  # Raised when the CPU type is unknown.
  class CPUTypeError < MachOError
    # @param num [Fixnum] the unknown number
    def initialize(num)
      super "Unrecognized CPU type: 0x#{"%02x" % num}"
    end
  end

  # Raised when the CPU subtype is unknown.
  class CPUSubtypeError < MachOError
    # @param num [Fixnum] the unknown number
    def initialize(num)
      super "Unrecognized CPU sub-type: 0x#{"%02x" % num}"
    end
  end

  # Raised when a mach-o file's filetype field is unknown.
  class FiletypeError < MachOError
    # @param num [Fixnum] the unknown number
    def initialize(num)
      super "Unrecognized Mach-O filetype code: 0x#{"%02x" % num}"
    end
  end

  # Raised when an unknown load command is encountered.
  class LoadCommandError < MachOError
    # @param num [Fixnum] the unknown number
    def initialize(num)
      super "Unrecognized Mach-O load command: 0x#{"%02x" % num}"
    end
  end

  # Raised when load commands are too large to fit in the current file.
  class HeaderPadError < MachOError
    # @param filename [String] the filename
    def initialize(filename)
      super "Updated load commands do not fit in the header of " +
      "#{filename}. #{filename} needs to be relinked, possibly with " +
      "-headerpad or -headerpad_max_install_names"
    end
  end

  # Raised when attempting to change a dylib name that doesn't exist.
  class DylibUnknownError < MachOError
    # @param dylib [String] the unknown shared library name
    def initialize(dylib)
      super "No such dylib name: #{dylib}"
    end
  end

  # Raised when attempting to change an rpath that doesn't exist.
  class RpathUnknownError < MachOError
    # @param path [String] the unknown runtime path
    def initialize(path)
      super "No such runtime path: #{path}"
    end
  end
end
