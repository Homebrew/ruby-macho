module MachO
	# load commands added after OS X 10.1 need to be bitwise ORed with
	# LC_REQ_DYLD to be recognized by the dynamic linder (dyld)
	LC_REQ_DYLD = 0x80000000

	# segment of this file to be mapped
	LC_SEGMENT = 0x1

	# link-edit stab symbol table info
	LC_SYMTAB = 0x2

	# link-edit gdb symbol table info (obsolete)
	LC_SYMSEG = 0x3

	# thread
	LC_THREAD = 0x4

	# unix thread (includes a stack)
	LC_UNIXTHREAD = 0x5

	# load a specified fixed VM shared library
	LC_LOADFVMLIB = 0x6

	# fixed VM shared library identification
	LC_IDFVMLIB = 0x7

	# object identification info (obsolete)
	LC_IDENT = 0x8

	# fixed VM file inclusion (internal use)
	LC_FVMFILE = 0x9

	# prepage command (internal use) 
	LC_PREPAGE = 0xa

	# dynamic link-edit symbol table info
	LC_DYSYMTAB = 0xb

	# load a dynamically linked shared library
	LC_LOAD_DYLIB = 0xc

	# dynamically linked shared lib ident
	LC_ID_DYLIB = 0xd

	# load a dynamic linker
	LC_LOAD_DYLINKER = 0xe

	# dynamic linker identification
	LC_ID_DYLINKER = 0xf

	# modules prebound for a dynamically linked shared library
	LC_PREBOUND_DYLIB = 0x10

	# image routines
	LC_ROUTINES = 0x11

	# sub framework
	LC_SUB_FRAMEWORK = 0x12

	# sub umbrella
	LC_SUB_UMBRELLA = 0x13

	# sub umbrella
	LC_SUB_CLIENT = 0x14

	# sub umbrella
	LC_SUB_LIBRARY = 0x15

	# two-level namespace lookup hints
	LC_TWOLEVEL_HINTS = 0x16

	# prebind checksum 
	LC_PREBIND_CKSUM = 0x17

	# load a dynamically linked shared library that is allowed to be missing (all symbols are weak imported).
	LC_LOAD_WEAK_DYLIB = (0x18 | LC_REQ_DYLD)

	# 64-bit segment of this file to be mapped
	LC_SEGMENT_64 = 0x19

	# 64-bit image routines
	LC_ROUTINES_64 = 0x1a

	# the uuid
	LC_UUID = 0x1b

	# runpath additions
	LC_RPATH = (0x1c | LC_REQ_DYLD)

	# local of code signature
	LC_CODE_SIGNATURE = 0x1d

	# local of info to split segments
	LC_SEGMENT_SPLIT_INFO = 0x1e

	# load and re-export dylib
	LC_REEXPORT_DYLIB = (0x1f | LC_REQ_DYLD)

	# delay load of dylib until first use
	LC_LAZY_LOAD_DYLIB = 0x20

	# encrypted segment information
	LC_ENCRYPTION_INFO = 0x21

	# compressed dyld information
	LC_DYLD_INFO = 0x22

	# compressed dyld information only
	LC_DYLD_INFO_ONLY = (0x22 | LC_REQ_DYLD)

	# load upward dylib
	LC_LOAD_UPWARD_DYLIB = (0x23 | LC_REQ_DYLD)

	# build for MacOSX min OS version
	LC_VERSION_MIN_MACOSX = 0x24

	# build for iPhoneOS min OS version
	LC_VERSION_MIN_IPHONEOS = 0x25

	# compressed table of function start addresses
	LC_FUNCTION_STARTS = 0x26

	# string for dyld to treat like environment variable
	LC_DYLD_ENVIRONMENT = 0x27

	# replacement for LC_UNIXTHREAD
	LC_MAIN = (0x28 | LC_REQ_DYLD)

	# table of non-instructions in __text
	LC_DATA_IN_CODE = 0x29

	# source version used to build binary
	LC_SOURCE_VERSION = 0x2a

	# Code signing DRs copied from linked dylibs
	LC_DYLIB_CODE_SIGN_DRS = 0x2b

	# 64-bit encrypted segment information
	LC_ENCRYPTION_INFO_64 = 0x2c

	# linker options in MH_OBJECT files
	LC_LINKER_OPTION = 0x2d

	# linker options in MH_OBJECT files
	LC_LINKER_OPTIMIZATION_HINT = 0x2e

	# association of load commands to string representations
	LOAD_COMMANDS = {
		LC_SEGMENT => "LC_SEGMENT",
		LC_SYMTAB => "LC_SYMTAB",
		LC_SYMSEG => "LC_SYMSEG",
		LC_THREAD => "LC_THREAD",
		LC_UNIXTHREAD => "LC_UNIXTHREAD",
		LC_LOADFVMLIB => "LC_LOADFVMLIB",
		LC_IDFVMLIB => "LC_IDFVMLIB",
		LC_IDENT => "LC_IDENT",
		LC_FVMFILE => "LC_FVMFILE",
		LC_PREPAGE => "LC_PREPAGE",
		LC_DYSYMTAB => "LC_DYSYMTAB",
		LC_LOAD_DYLIB => "LC_LOAD_DYLIB",
		LC_ID_DYLIB => "LC_ID_DYLIB",
		LC_LOAD_DYLINKER => "LC_LOAD_DYLINKER",
		LC_ID_DYLINKER => "LC_ID_DYLINKER",
		LC_PREBOUND_DYLIB => "LC_PREBOUND_DYLIB",
		LC_ROUTINES => "LC_ROUTINES",
		LC_SUB_FRAMEWORK => "LC_SUB_FRAMEWORK",
		LC_SUB_UMBRELLA => "LC_SUB_UMBRELLA",
		LC_SUB_CLIENT => "LC_SUB_CLIENT",
		LC_SUB_LIBRARY => "LC_SUB_LIBRARY",
		LC_TWOLEVEL_HINTS => "LC_TWOLEVEL_HINTS",
		LC_PREBIND_CKSUM => "LC_PREBIND_CKSUM",
		LC_LOAD_WEAK_DYLIB => "LC_LOAD_WEAK_DYLIB",
		LC_SEGMENT_64 => "LC_SEGMENT_64",
		LC_ROUTINES_64 => "LC_ROUTINES_64",
		LC_UUID => "LC_UUID",
		LC_RPATH => "LC_RPATH",
		LC_CODE_SIGNATURE => "LC_CODE_SIGNATURE",
		LC_SEGMENT_SPLIT_INFO => "LC_SEGMENT_SPLIT_INFO",
		LC_REEXPORT_DYLIB => "LC_REEXPORT_DYLIB",
		LC_LAZY_LOAD_DYLIB => "LC_LAZY_LOAD_DYLIB",
		LC_ENCRYPTION_INFO => "LC_ENCRYPTION_INFO",
		LC_DYLD_INFO => "LC_DYLD_INFO",
		LC_DYLD_INFO_ONLY => "LC_DYLD_INFO_ONLY",
		LC_LOAD_UPWARD_DYLIB => "LC_LOAD_UPWARD_DYLIB",
		LC_VERSION_MIN_MACOSX => "LC_VERSION_MIN_MACOSX",
		LC_VERSION_MIN_IPHONEOS => "LC_VERSION_MIN_IPHONEOS",
		LC_FUNCTION_STARTS => "LC_FUNCTION_STARTS",
		LC_DYLD_ENVIRONMENT => "LC_DYLD_ENVIRONMENT",
		LC_MAIN => "LC_MAIN",
		LC_DATA_IN_CODE => "LC_DATA_IN_CODE",
		LC_SOURCE_VERSION => "LC_SOURCE_VERSION",
		LC_DYLIB_CODE_SIGN_DRS => "LC_DYLIB_CODE_SIGN_DRS",
		LC_ENCRYPTION_INFO_64 => "LC_ENCRYPTION_INFO_64",
		LC_LINKER_OPTION => "LC_LINKER_OPTION",
		LC_LINKER_OPTIMIZATION_HINT => "LC_LINKER_OPTIMIZATION_HINT"
	}

	# association of load commands to string representations of class names
	LC_STRUCTURES = {
		LC_SEGMENT => "SegmentCommand",
		LC_SYMTAB => "SymtabCommand",
		LC_SYMSEG => "LoadCommand", # obsolete
		LC_THREAD => "ThreadCommand",
		LC_UNIXTHREAD => "ThreadCommand",
		LC_LOADFVMLIB => "LoadCommand", # obsolete
		LC_IDFVMLIB => "LoadCommand", # obsolete
		LC_IDENT => "LoadCommand", # obsolete
		LC_FVMFILE => "LoadCommand", # reserved for internal use only
		LC_PREPAGE => "LoadCommand", # reserved for internal use only
		LC_DYSYMTAB => "DysymtabCommand",
		LC_LOAD_DYLIB => "DylibCommand",
		LC_ID_DYLIB => "DylibCommand",
		LC_LOAD_DYLINKER => "DylinkerCommand",
		LC_ID_DYLINKER => "DylinkerCommand",
		LC_PREBOUND_DYLIB => "PreboundDylibCommand",
		LC_ROUTINES => "RoutinesCommand",
		LC_SUB_FRAMEWORK => "SubFrameworkCommand",
		LC_SUB_UMBRELLA => "SubUmbrellaCommand",
		LC_SUB_CLIENT => "SubClientCommand",
		LC_SUB_LIBRARY => "SubLibraryCommand",
		LC_TWOLEVEL_HINTS => "TwolevelHintsCommand",
		LC_PREBIND_CKSUM => "PrebindCksumCommand",
		LC_LOAD_WEAK_DYLIB => "DylibCommand",
		LC_SEGMENT_64 => "SegmentCommand64",
		LC_ROUTINES_64 => "RoutinesCommand64",
		LC_UUID => "UUIDCommand",
		LC_RPATH => "RpathCommand",
		LC_CODE_SIGNATURE => "LinkeditDataCommand",
		LC_SEGMENT_SPLIT_INFO => "LinkeditDataCommand",
		LC_REEXPORT_DYLIB => "DylibCommand",
		LC_LAZY_LOAD_DYLIB => "LoadCommand", # undoc, maybe DylibCommand?
		LC_ENCRYPTION_INFO => "EncryptionInfoCommand",
		LC_DYLD_INFO => "DyldInfoCommand",
		LC_DYLD_INFO_ONLY => "DyldInfoCommand",
		LC_LOAD_UPWARD_DYLIB => "LoadCommand", # undoc, maybe DylibCommand?
		LC_VERSION_MIN_MACOSX => "VersionMinCommand",
		LC_VERSION_MIN_IPHONEOS => "VersionMinCommand",
		LC_FUNCTION_STARTS => "LinkeditDataCommand",
		LC_DYLD_ENVIRONMENT => "DylinkerCommand",
		LC_MAIN => "EntryPointCommand",
		LC_DATA_IN_CODE => "LinkeditDataCommand",
		LC_SOURCE_VERSION => "SourceVersionCommand",
		LC_DYLIB_CODE_SIGN_DRS => "LinkeditDataCommand",
		LC_ENCRYPTION_INFO_64 => "EncryptionInfoCommand64",
		LC_LINKER_OPTION => "LinkerOptionCommand",
		LC_LINKER_OPTIMIZATION_HINT => "LinkeditDataCommand"
	}

	# pagezero segment name
	SEG_PAGEZERO = "__PAGEZERO"

	# text segment name
	SEG_TEXT = "__TEXT"

	# data segment name
	SEG_DATA = "__DATA"

	# objective-c runtime segment
	SEG_OBJC = "__OBJC"

	# icon segment
	SEG_ICON = "__ICON"

	# link editor structures segment
	SEG_LINKEDIT = "__LINKEDIT"

	# unix stack segment
	SEG_UNIXSTACK = "__UNIXSTACK"

	# segment for self-modifying code with RWX permissions
	SEG_IMPORT = "__IMPORT"

	# the file contents for this segment is for the high part of the VM space, the low part is zero filled (for stacks in core files)
	SG_HIGHVM = 0x1

	# this segment is the VM that is allocated by a fixed VM library, for overlap checking in the link editor
	SG_FVMLIB = 0x2

	# this segment has nothing that was relocated in it and nothing relocated to it, that is it maybe safely replaced without relocation
	SG_NORELOC = 0x4

	# this segment is protected.  if the segment starts at file offset 0, the first page of the segment is not protected.  all other pages of the segment are protected.
	SG_PROTECTED_VERSION_1 = 0x8

	# Mach-O load command structure
	# This is the most generic load command - only cmd ID and size are
	# represented, and no actual data. Used when a more specific class
	# isn't available/implemented.
	class LoadCommand < MachOStructure
		# @return [Fixnum] the offset in the file the command was created from
		attr_reader :offset

		# @return [Fixnum] the load command's identifying number
		attr_reader :cmd

		# @return [Fixnum] the size of the load command, in bytes
		attr_reader :cmdsize

		@format = "VV"
		@sizeof = 8

		# Creates a new LoadCommand given an offset and binary string
		# @param offset [Fixnum] the offset to initialize with
		# @param bin [String] the binary string to initialize with
		# @return [MachO::LoadCommand] the new load command
		# @private
		def self.new_from_bin(raw_data, offset, bin)
			self.new(raw_data, offset, *bin.unpack(@format))
		end

		# @param offset [Fixnum] the offset to initialize iwth
		# @param cmd [Fixnum] the load command's identifying number
		# @param cmdsize [Fixnum] the size of the load command in bytes
		# @private
		def initialize(raw_data, offset, cmd, cmdsize)
			@raw_data = raw_data
			@offset = offset
			@cmd = cmd
			@cmdsize = cmdsize
		end

		# @return [String] a string representation of the load command's identifying number
		def to_s
			LOAD_COMMANDS[cmd]
		end
	end

	# A load command containing a single 128-bit unique random number identifying
	# an object produced by static link editor. Corresponds to LC_UUID.
	class UUIDCommand < LoadCommand
		# @return [Array<Fixnum>] the UUID
		attr_reader :uuid

		@format = "VVa16"
		@sizeof = 24

		# @private
		def initialize(raw_data, offset, cmd, cmdsize, uuid)
			super(raw_data, offset, cmd, cmdsize)
			@uuid = uuid.unpack("C16") # re-unpack for the actual UUID array
		end

		# @return [String] a string representation of the UUID
		def uuid_string
			hexes = uuid.map { |e| "%02x" % e }
			segs = [
				hexes[0..3].join, hexes[4..5].join,	hexes[6..7].join,
				hexes[8..9].join, hexes[10..15].join
			]

			segs.join("-")
		end
	end

	# A load command indicating that part of this file is to be mapped into
	# the task's address space. Corresponds to LC_SEGMENT.
	class SegmentCommand < LoadCommand
		# @return [String] the name of the segment, including null padding bytes
		attr_reader :segname

		# @return [Fixnum] the memory address of the segment
		attr_reader :vmaddr

		# @return [Fixnum] the memory size of the segment
		attr_reader :vmsize

		# @return [Fixnum] the file offset of the segment
		attr_reader :fileoff

		# @return [Fixnum] the amount to map from the file
		attr_reader :filesize

		# @return [Fixnum] the maximum VM protection
		attr_reader :maxprot

		# @return [Fixnum] the initial VM protection
		attr_reader :initprot

		# @return [Fixnum] the number of sections in the segment
		attr_reader :nsects

		# @return [Fixnum] any flags associated with the segment
		attr_reader :flags

		@format = "VVa16VVVVVVVV"
		@sizeof = 56

		# @private
		def initialize(raw_data, offset, cmd, cmdsize, segname, vmaddr, vmsize, fileoff,
				filesize, maxprot, initprot, nsects, flags)
			super(raw_data, offset, cmd, cmdsize)
			@segname = segname
			@vmaddr = vmaddr
			@vmsize = vmsize
			@fileoff = fileoff
			@filesize = filesize
			@maxprot = maxprot
			@initprot = initprot
			@nsects = nsects
			@flags = flags
		end

		# @return [String] the segment's name, with any trailing NULL characters removed
		def segment_name
			@segname.delete("\x00")
		end
	end

	# A load command indicating that part of this file is to be mapped into
	# the task's address space. Corresponds to LC_SEGMENT_64.
	class SegmentCommand64 < LoadCommand
		# @return [String] the name of the segment, including null padding bytes
		attr_reader :segname

		# @return [Fixnum] the memory address of the segment
		attr_reader :vmaddr

		# @return [Fixnum] the memory size of the segment
		attr_reader :vmsize

		# @return [Fixnum] the file offset of the segment
		attr_reader :fileoff

		# @return [Fixnum] the amount to map from the file
		attr_reader :filesize

		# @return [Fixnum] the maximum VM protection
		attr_reader :maxprot

		# @return [Fixnum] the initial VM protection
		attr_reader :initprot

		# @return [Fixnum] the number of sections in the segment
		attr_reader :nsects

		# @return [Fixnum] any flags associated with the segment
		attr_reader :flags

		@format = "VVa16QQQQVVVV"
		@sizeof = 72

		# @private
		def initialize(raw_data, offset, cmd, cmdsize, segname, vmaddr, vmsize, fileoff,
				filesize, maxprot, initprot, nsects, flags)
			super(raw_data, offset, cmd, cmdsize)
			@segname = segname
			@vmaddr = vmaddr
			@vmsize = vmsize
			@fileoff = fileoff
			@filesize = filesize
			@maxprot = maxprot
			@initprot = initprot
			@nsects = nsects
			@flags = flags
		end

		# @return [String] the segment's name, with any trailing NULL characters removed
		def segment_name
			@segname.delete("\x00")
		end
	end

	# A load command representing some aspect of shared libraries, depending
	# on filetype. Corresponds to LC_ID_DYLIB, LC_LOAD_DYLIB, LC_LOAD_WEAK_DYLIB,
	# and LC_REEXPORT_DYLIB.
	class DylibCommand < LoadCommand
		# @return [Fixnum] the library's path name (lc_str)
		attr_reader :name

		# @return [Fixnum] the library's build time stamp
		attr_reader :timestamp

		# @return [Fixnum] the library's current version number
		attr_reader :current_version

		# @return [Fixnum] the library's compatibility version number
		attr_reader :compatibility_version

		@format = "VVVVVV"
		@sizeof = 24

		# @private
		def initialize(raw_data, offset, cmd, cmdsize, name, timestamp, current_version,
				compatibility_version)
			super(raw_data, offset, cmd, cmdsize)
			@name = name
			@timestamp = timestamp
			@current_version = current_version
			@compatibility_version = compatibility_version
		end
	end

	# A load command representing some aspect of the dynamic linker, depending
	# on filetype. Corresponds to LC_ID_DYLINKER, LC_LOAD_DYLINKER, and
	# LC_DYLD_ENVIRONMENT.
	class DylinkerCommand < LoadCommand
		# @return [Fixnum] the dynamic linker's path name (lc_str)
		attr_reader :name

		@format = "VVV"
		@sizeof = 12

		# @private
		def initialize(raw_data, offset, cmd, cmdsize, name)
			super(raw_data, offset, cmd, cmdsize)
			@name = name
		end
	end

	# A load command used to indicate dynamic libraries used in prebinding.
	# Corresponds to LC_PREBOUND_DYLIB.
	class PreboundDylibCommand < LoadCommand
		# @return [Fixnum] the library's path name (lc_str)
		attr_reader :name

		# @return [Fixnum] the number of modules in the library
		attr_reader :nmodules

		# @return [Fixnum] a bit vector of linked modules
		attr_reader :linked_modules

		@format = "VVVVV"
		@sizeof = 20

		# @private
		def initialize(raw_data, offset, cmd, cmdsize, name, nmodules, linked_modules)
			super(raw_data, offset, cmd, cmdsize)
			@name = name
			@nmodules = nmodules
			@linked_modules = linked_modules
		end
	end

	# A load command used to represent threads.
	# @note cctools-870 has all fields of thread_command commented out except common ones (cmd, cmdsize)
	class ThreadCommand < LoadCommand

	end

	# A load command containing the address of the dynamic shared library
	# initialization routine and an index into the module table for the module
	# that defines the routine. Corresponds to LC_ROUTINES.
	class RoutinesCommand < LoadCommand
		# @return [Fixnum] the address of the initialization routine
		attr_reader :init_address

		# @return [Fixnum] the index into the module table that the init routine is defined in
		attr_reader :init_module

		# @return [void]
		attr_reader :reserved1

		# @return [void]
		attr_reader :reserved2

		# @return [void]
		attr_reader :reserved3

		# @return [void]
		attr_reader :reserved4

		# @return [void]
		attr_reader :reserved5

		# @return [void]
		attr_reader :reserved6

		@format = "VVVVVVVVVV"
		@sizeof = 40

		# @private
		def initialize(raw_data, offset, cmd, cmdsize, init_address, init_module,
				reserved1, reserved2, reserved3, reserved4, reserved5,
				reserved6)
			super(raw_data, offset, cmd, cmdsize)
			@init_address = init_address
			@init_module = init_module
			@reserved1 = reserved1
			@reserved2 = reserved2
			@reserved3 = reserved3
			@reserved4 = reserved4
			@reserved5 = reserved5
			@reserved6 = reserved6
		end
	end

	# A load command containing the address of the dynamic shared library
	# initialization routine and an index into the module table for the module
	# that defines the routine. Corresponds to LC_ROUTINES_64.
	class RoutinesCommand64 < LoadCommand
		# @return [Fixnum] the address of the initialization routine
		attr_reader :init_address

		# @return [Fixnum] the index into the module table that the init routine is defined in
		attr_reader :init_module

		# @return [void]
		attr_reader :reserved1

		# @return [void]
		attr_reader :reserved2

		# @return [void]
		attr_reader :reserved3

		# @return [void]
		attr_reader :reserved4

		# @return [void]
		attr_reader :reserved5

		# @return [void]
		attr_reader :reserved6

		@format = "VVQQQQQQQQ"
		@sizeof = 72

		# @private
		def initialize(raw_data, offset, cmd, cmdsize, init_address, init_module,
				reserved1, reserved2, reserved3, reserved4, reserved5,
				reserved6)
			super(raw_data, offset, cmd, cmdsize)
			@init_address = init_address
			@init_module = init_module
			@reserved1 = reserved1
			@reserved2 = reserved2
			@reserved3 = reserved3
			@reserved4 = reserved4
			@reserved5 = reserved5
			@reserved6 = reserved6
		end
	end

	# A load command signifying membership of a subframework containing the name
	# of an umbrella framework. Corresponds to LC_SUB_FRAMEWORK.
	class SubFrameworkCommand < LoadCommand
		# @return [Fixnum] the umbrella framework name (lc_str)
		attr_reader :umbrella

		@format = "VVV"
		@sizeof = 12

		# @private
		def initialize(raw_data, offset, cmd, cmdsize, umbrella)
			super(raw_data, offset, cmd, cmdsize)
			@umbrella = umbrella
		end
	end

	# A load command signifying membership of a subumbrella containing the name
	# of an umbrella framework. Corresponds to LC_SUB_UMBRELLA.
	class SubUmbrellaCommand < LoadCommand
		# @return [Fixnum] the subumbrella framework name (lc_str)
		attr_reader :sub_umbrella

		@format = "VVV"
		@sizeof = 12

		# @private
		def initialize(raw_data, offset, cmd, cmdsize, sub_umbrella)
			super(raw_data, offset, cmd, cmdsize)
			@sub_umbrella = sub_umbrella
		end
	end

	# A load command signifying a sublibrary of a shared library. Corresponds
	# to LC_SUB_LIBRARY.
	class SubLibraryCommand < LoadCommand
		# @return [Fixnum] the sublibrary name (lc_str)
		attr_reader :sub_library

		@format = "VVV"
		@sizeof = 12

		# @private
		def initialize(raw_data, offset, cmd, cmdsize, sub_library)
			super(raw_data, offset, cmd, cmdsize)
			@sub_library = sub_library
		end
	end

	# A load command signifying a shared library that is a subframework of
	# an umbrella framework. Corresponds to LC_SUB_CLIENT.
	class SubClientCommand < LoadCommand
		# @return [Fixnum] the subclient name (lc_str)
		attr_reader :sub_client

		@format = "VVV"
		@sizeof = 12

		# @private
		def initialize(raw_data, offset, cmd, cmdsize, sub_client)
			super(raw_data, offset, cmd, cmdsize)
			@sub_client = sub_client
		end
	end

	# A load command containing the offsets and sizes of the link-edit 4.3BSD
	# "stab" style symbol table information. Corresponds to LC_SYMTAB.
	class SymtabCommand < LoadCommand
		# @return [Fixnum] the symbol table's offset
		attr_reader :symoff

		# @return [Fixnum] the number of symbol table entries
		attr_reader :nsyms

		# @return the string table's offset
		attr_reader :stroff

		# @return the string table size in bytes
		attr_reader :strsize

		@format = "VVVVVV"
		@sizeof = 24

		# @private
		def initialize(raw_data, offset, cmd, cmdsize, symoff, nsyms, stroff, strsize)
			super(raw_data, offset, cmd, cmdsize)
			@symoff = symoff
			@nsyms = nsyms
			@stroff = stroff
			@strsize = strsize
		end
	end

	# A load command containing symbolic information needed to support data
	# structures used by the dynamic link editor. Corresponds to LC_DYSYMTAB.
	class DysymtabCommand < LoadCommand
		# @return [Fixnum] the index to local symbols
		attr_reader :ilocalsym

		# @return [Fixnum] the number of local symbols
		attr_reader :nlocalsym

		# @return [Fixnum] the index to externally defined symbols
		attr_reader :iextdefsym

		# @return [Fixnum] the number of externally defined symbols
		attr_reader :nextdefsym

		# @return [Fixnum] the index to undefined symbols
		attr_reader :iundefsym

		# @return [Fixnum] the number of undefined symbols
		attr_reader :nundefsym

		# @return [Fixnum] the file offset to the table of contents
		attr_reader :tocoff

		# @return [Fixnum] the number of entries in the table of contents
		attr_reader :ntoc

		# @return [Fixnum] the file offset to the module table
		attr_reader :modtaboff

		# @return [Fixnum] the number of entries in the module table
		attr_reader :nmodtab

		# @return [Fixnum] the file offset to the referenced symbol table
		attr_reader :extrefsymoff

		# @return [Fixnum] the number of entries in the referenced symbol table
		attr_reader :nextrefsyms

		# @return [Fixnum] the file offset to the indirect symbol table
		attr_reader :indirectsymoff

		# @return [Fixnum] the number of entries in the indirect symbol table
		attr_reader :nindirectsyms

		# @return [Fixnum] the file offset to the external relocation entries
		attr_reader :extreloff

		# @return [Fixnum] the number of external relocation entries
		attr_reader :nextrel

		# @return [Fixnum] the file offset to the local relocation entries
		attr_reader :locreloff

		# @return [Fixnum] the number of local relocation entries
		attr_reader :nlocrel


		@format = "VVVVVVVVVVVVVVVVVVVV"
		@sizeof = 80

		# ugh
		# @private
		def initialize(raw_data, offset, cmd, cmdsize, ilocalsym, nlocalsym, iextdefsym,
				nextdefsym, iundefsym, nundefsym, tocoff, ntoc, modtaboff,
				nmodtab, extrefsymoff, nextrefsyms, indirectsymoff,
				nindirectsyms, extreloff, nextrel, locreloff, nlocrel)
			super(raw_data, offset, cmd, cmdsize)
			@ilocalsym = ilocalsym
			@nlocalsym = nlocalsym
			@iextdefsym = iextdefsym
			@nextdefsym = nextdefsym
			@iundefsym = iundefsym
			@nundefsym = nundefsym
			@tocoff = tocoff
			@ntoc = ntoc
			@modtaboff = modtaboff
			@nmodtab = nmodtab
			@extrefsymoff = extrefsymoff
			@nextrefsyms = nextrefsyms
			@indirectsymoff = indirectsymoff
			@nindirectsyms = nindirectsyms
			@extreloff = extreloff
			@nextrel = nextrel
			@locreloff = locreloff
			@nlocrel = nlocrel
		end
	end

	# A load command containing the offset and number of hints in the two-level
	# namespace lookup hints table. Corresponds to LC_TWOLEVEL_HINTS.
	class TwolevelHintsCommand < LoadCommand
		# @return [Fixnum] the offset to the hint table
		attr_reader :htoffset

		# @return [Fixnum] the number of hints in the hint table
		attr_reader :nhints

		@format = "VVVV"
		@sizeof = 16

		# @private
		def initialize(raw_data, offset, cmd, cmdsize, htoffset, nhints)
			super(raw_data, offset, cmd, cmdsize)
			@htoffset = htoffset
			@nhints = nhints
		end
	end

	# A load command containing the value of the original checksum for prebound
	# files, or zero. Corresponds to LC_PREBIND_CKSUM.
	class PrebindCksumCommand < LoadCommand
		# @return [Fixnum] the checksum or 0
		attr_reader :cksum

		@format = "VVV"
		@sizeof = 12

		# @private
		def initialize(raw_data, offset, cmd, cmdsize, cksum)
			super(raw_data, offset, cmd, cmdsize)
			@cksum = cksum
		end
	end

	# A load command representing an rpath, which specifies a path that should
	# be added to the current run path used to find @rpath prefixed dylibs.
	# Corresponds to LC_RPATH.
	class RpathCommand < LoadCommand
		# @return [Fixnum] the oath to add to the run path (lc_str)
		attr_reader :path

		@format = "VVV"
		@sizeof = 12

		# @private
		def initialize(raw_data, offset, cmd, cmdsize, path)
			super(raw_data, offset, cmd, cmdsize)
			@path = path
		end
	end

	# A load command representing the offsets and sizes of a blob of data in
	# the __LINKEDIT segment. Corresponds to LC_CODE_SIGNATURE, LC_SEGMENT_SPLIT_INFO,
	# LC_FUNCTION_STARTS, LC_DATA_IN_CODE, LC_DYLIB_CODE_SIGN_DRS, and LC_LINKER_OPTIMIZATION_HINT.
	class LinkeditDataCommand < LoadCommand
		# @return [Fixnum] offset to the data in the __LINKEDIT segment
		attr_reader :dataoff

		# @return [Fixnum] size of the data in the __LINKEDIT segment
		attr_reader :datasize

		@format = "VVVV"
		@sizeof = 16

		# @private
		def initialize(raw_data, offset, cmd, cmdsize, dataoff, datasize)
			super(raw_data, offset, cmd, cmdsize)
			@dataoff = dataoff
			@datasize = datasize
		end
	end

	# A load command representing the offset to and size of an encrypted
	# segment. Corresponds to LC_ENCRYPTION_INFO.
	class EncryptionInfoCommand < LoadCommand
		# @return [Fixnum] the offset to the encrypted segment
		attr_reader :cryptoff

		# @return [Fixnum] the size of the encrypted segment
		attr_reader :cryptsize

		# @return [Fixnum] the encryption system, or 0 if not encrypted yet
		attr_reader :cryptid

		@format = "VVVVV"
		@sizeof = 20

		# @private
		def initialize(raw_data, offset, cmd, cmdsize, cryptoff, cryptsize, cryptid)
			super(raw_data, offset, cmd, cmdsize)
			@cryptoff = cryptoff
			@cryptsize = cryptsize
			@cryptid = cryptid
		end
	end

	# A load command representing the offset to and size of an encrypted
	# segment. Corresponds to LC_ENCRYPTION_INFO_64.
	class EncryptionInfoCommand64 < LoadCommand
		# @return [Fixnum] the offset to the encrypted segment
		attr_reader :cryptoff

		# @return [Fixnum] the size of the encrypted segment
		attr_reader :cryptsize

		# @return [Fixnum] the encryption system, or 0 if not encrypted yet
		attr_reader :cryptid

		# @return [Fixnum] 64-bit padding value
		attr_reader :pad

		@format = "VVVVVV"
		@sizeof = 24

		# @private
		def initialize(raw_data, offset, cmd, cmdsize, cryptoff, cryptsize, cryptid)
			super(raw_data, offset, cmd, cmdsize)
			@cryptoff = cryptoff
			@cryptsize = cryptsize
			@cryptid = cryptid
			@pad = pad
		end
	end

	# A load command containing the minimum OS version on which the binary
	# was built to run. Corresponds to LC_VERSION_MIN_MACOSX and LC_VERSION_MIN_IPHONEOS.
	class VersionMinCommand < LoadCommand
		# @return [Fixnum] the version X.Y.Z packed as x16.y8.z8
		attr_reader :version

		# @return [Fixnum] the SDK version X.Y.Z packed as x16.y8.z8
		attr_reader :sdk

		@format = "VVVV"
		@sizeof = 16

		# @private
		def initialize(raw_data, offset, cmd, cmdsize, version, sdk)
			super(raw_data, offset, cmd, cmdsize)
			@version = version
			@sdk = sdk
		end

		# A string representation of the binary's minimum OS version.
		# @return [String] a string representing the minimum OS version.
		def version_string
			binary = "%032b" % version
			segs = [
				binary[0..15], binary[16..23], binary[24..31]
			].map { |s| s.to_i(2) }

			segs.join(".")
		end

		# A string representation of the binary's SDK version.
		# @return [String] a string representing the SDK version.
		def sdk_string
			binary = "%032b" % sdk
			segs = [
				binary[0..15], binary[16..23], binary[24..31]
			].map { |s| s.to_i(2) }

			segs.join(".")
		end
	end

	# A load command containing the file offsets and sizes of the new
	# compressed form of the information dyld needs to load the image.
	# Corresponds to LC_DYLD_INFO and LC_DYLD_INFO_ONLY.
	class DyldInfoCommand < LoadCommand
		# @return [Fixnum] the file offset to the rebase information
		attr_reader :rebase_off

		# @return [Fixnum] the size of the rebase information
		attr_reader :rebase_size

		# @return [Fixnum] the file offset to the binding information
		attr_reader :bind_off

		# @return [Fixnum] the size of the binding information
		attr_reader :bind_size

		# @return [Fixnum] the file offset to the weak binding information
		attr_reader :weak_bind_off

		# @return [Fixnum] the size of the weak binding information
		attr_reader :weak_bind_size

		# @return [Fixnum] the file offset to the lazy binding information
		attr_reader :lazy_bind_off

		# @return [Fixnum] the size of the lazy binding information
		attr_reader :lazy_bind_size

		# @return [Fixnum] the file offset to the export information
		attr_reader :export_off

		# @return [Fixnum] the size of the export information
		attr_reader :export_size

		@format = "VVVVVVVVVVVV"
		@sizeof = 48

		# @private
		def initialize(raw_data, offset, cmd, cmdsize, rebase_off, rebase_size, bind_off,
				bind_size, weak_bind_off, weak_bind_size, lazy_bind_off,
				lazy_bind_size, export_off, export_size)
			super(raw_data, offset, cmd, cmdsize)
			@rebase_off = rebase_off
			@rebase_size = rebase_size
			@bind_off = bind_off
			@bind_size = bind_size
			@weak_bind_off = weak_bind_off
			@weak_bind_size = weak_bind_size
			@lazy_bind_off = lazy_bind_off
			@lazy_bind_size = lazy_bind_size
			@export_off = export_off
			@export_size = export_size
		end
	end

	# A load command containing linker options embedded in object files.
	# Corresponds to LC_LINKER_OPTION.
	class LinkerOptionCommand < LoadCommand
		# @return [Fixnum] the number of strings
		attr_reader :count

		@format = "VVV"
		@sizeof = 12

		# @private
		def initialize(raw_data, offset, cmd, cmdsize, count)
			super(raw_data, offset, cmd, cmdsize)
			@count = count
		end
	end

	# A load command specifying the offset of main(). Corresponds to LC_MAIN.
	class EntryPointCommand < LoadCommand
		# @return [Fixnum] the file (__TEXT) offset of main()
		attr_reader :entryoff

		# @return [Fixnum] if not 0, the initial stack size.
		attr_reader :stacksize

		@format = "VVQQ"
		@sizeof = 24

		# @private
		def initialize(raw_data, offset, cmd, cmdsize, entryoff, stacksize)
			super(raw_data, offset, cmd, cmdsize)
			@entryoff = entryoff
			@stacksize = stacksize
		end
	end

	# A load command specifying the version of the sources used to build the
	# binary. Corresponds to LC_SOURCE_VERSION.
	class SourceVersionCommand < LoadCommand
		# @return [Fixnum] the version packed as a24.b10.c10.d10.e10
		attr_reader :version

		@format = "VVQ"
		@sizeof = 16

		# @private
		def initialize(raw_data, offset, cmd, cmdsize, version)
			super(raw_data, offset, cmd, cmdsize)
			@version = version
		end

		# A string representation of the sources used to build the binary.
		# @return [String] a string representation of the version
		def version_string
			binary = "%064b" % version
			segs = [
				binary[0..23], binary[24..33], binary[34..43], binary[44..53],
				binary[54..63]
			].map { |s| s.to_i(2) }

			segs.join(".")
		end
	end
end
