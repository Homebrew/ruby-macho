require "./lib/cstruct.rb"
require "./lib/macho/file"
require "./lib/macho/exceptions"

# http://www.opensource.apple.com/source/cctools/cctools-870/include/mach-o/loader.h
# http://www.opensource.apple.com/source/cctools/cctools-870/include/mach-o/fat.h

module MachO
	# 'Fat' binaries envelop Mach-O binaries so include them for completeness,
	# Fat binary header structure
	class FatHeader < CStruct
		uint32 :magic
		uint32 :nfat_arch # number of FatArchs that follow
	end

	# Fat binary architecture structure
	class FatArch < CStruct
		int32 :cputype
		int32 :cpusubtype
		uint32 :offset
		uint32 :size
		uint32 :align
	end

	FAT_MAGIC = 0xcafebabe # big-endian fat magic
	FAT_CIGAM = 0xbebafeca # little-endian fat magic

	# 32-bit Mach-O file header structure
	class MachHeader < CStruct
		uint32 :magic
		int32 :cputype
		int32 :cpusubtype
		uint32 :filetype
		uint32 :ncmds
		uint32 :sizeofcmds
		uint32 :flags
	end

	MH_MAGIC = 0xfeedface # 32-bit big-endian magic
	MH_CIGAM = 0xcefaedfe # 32-bit little-endian magic

	# 64-bit Mach-O file header structure
	class MachHeader64 < CStruct
		uint32 :magic
		int32 :cputype
		int32 :cpusubtype
		uint32 :filetype
		uint32 :ncmds
		uint32 :sizeofcmds
		uint32 :flags
		uint32 :reserved
	end

	MH_MAGIC_64 = 0xfeedfacf # 64-bit big-endian magic
	MH_CIGAM_64 = 0xcffaedfe # 64-bit little-endian magic

	MH_MAGICS = {
		FAT_MAGIC => "FAT_MAGIC",
		FAT_CIGAM => "FAT_CIGAM",
		MH_MAGIC => "MH_MAGIC",
		MH_CIGAM => "MH_CIGAM",
		MH_MAGIC_64 => "MH_MAGIC_64",
		MH_CIGAM_64 => "MH_CIGAM_64"
	}

	# capability bits used in the definition of cputype
	CPU_ARCH_MASK = 0xff000000
	CPU_ARCH_ABI64 = 0x01000000

	# (select) values for cputype in MachHeader/MachHeader64
	CPU_TYPE_ANY = -1
	CPU_TYPE_X86 = 0x07
	CPU_TYPE_I386 = CPU_TYPE_X86
	CPU_TYPE_X86_64 = (CPU_TYPE_X86 | CPU_ARCH_ABI64)
	CPU_TYPE_POWERPC = 0x24 # 18
	CPU_TYPE_POWERPC64 = (CPU_TYPE_POWERPC | CPU_ARCH_ABI64)

	# convenience array of CPU types
	CPU_TYPES = {
		CPU_TYPE_ANY => "CPU_TYPE_ANY",
		CPU_TYPE_X86 => "CPU_TYPE_X86",
		CPU_TYPE_I386 => "CPU_TYPE_I386",
		CPU_TYPE_X86_64 => "CPU_TYPE_X86_64",
		CPU_TYPE_POWERPC => "CPU_TYPE_POWERPC",
		CPU_TYPE_POWERPC64 => "CPU_TYPE_POWERPC64"
	}

	# (select) cpusubtypes
	CPU_SUBTYPE_X86_ALL = 3
	CPU_SUBTYPE_X86_ARCH1 = 4

	CPU_SUBTYPES = {
		CPU_SUBTYPE_X86_ALL => "CPU_SUBTYPE_X86_ALL",
		CPU_SUBTYPE_X86_ARCH1 => "CPU_SUBTYPE_X86_ARCH1"
	}

	# values for filetype in MachHeader/MachHeader64
	MH_OBJECT = 0x1			# relocatable object file
	MH_EXECUTE = 0x2		# demand paged executable file
	MH_FVMLIB = 0x3			# fixed VM shared library file
	MH_CORE = 0x4			# core file
	MH_PRELOAD = 0x5		# preloaded executable file
	MH_DYLIB = 0x6			# dynamically bound shared library
	MH_DYLINKER = 0x7		# dynamic link editor
	MH_BUNDLE = 0x8			# dynamically bound bundle file
	MH_DYLIB_STUB = 0x9		# shared library stub for static linking only no,
							# section contents
	MH_DSYM = 0xa			# companion file with only debug sections
	MH_KEXT_BUNDLE = 0xb	# x86_64 lexts

	MH_FILETYPES = {
		MH_OBJECT => "MH_OBJECT",
		MH_EXECUTE => "MH_EXECUTE",
		MH_FVMLIB => "MH_FVMLIB",
		MH_CORE => "MH_CORE",
		MH_PRELOAD => "MH_PRELOAD",
		MH_DYLIB => "MH_DYLIB",
		MH_DYLINKER => "MH_DYLINKER",
		MH_BUNDLE => "MH_BUNDLE",
		MH_DYLIB_STUB => "MH_DYLIB_STUB",
		MH_DSYM => "MH_DSYM",
		MH_KEXT_BUNDLE => "MH_KEXT_BUNDLE"
	}

	# TODO: declare values for flags in MachHeader/MachHeader64

	# Mach-O load command structure
	class LoadCommand < CStruct
		uint32 :cmd
		uint32 :cmdsize
	end

	# After MacOS X 10.1 when a new load command is added that is required to be
	# understood by the dynamic linker for the image to execute properly the
	# LC_REQ_DYLD bit will be or'ed into the load command constant.  If the dynamic
	# linker sees such a load command it it does not understand will issue a
	# "unknown load command required for execution" error and refuse to use the
	# image.  Other load commands without this bit that are not understood will
	# simply be ignored.
	LC_REQ_DYLD = 0x80000000

	# values for cmd in LoadCommand
	LC_SEGMENT = 0x1
	LC_SYMTAB = 0x2
	LC_SYMSEC = 0x3
	LC_THREAD = 0x4
	LC_UNIXTHREAD = 0x5
	LC_LOADFVMLIB = 0x6
	LC_IDFVMLIB = 0x7
	LC_IDENT = 0x8
	LC_FVMFILE = 0x9
	LC_PREPAGE = 0xa
	LC_DSYMTAB = 0xb
	LC_LOAD_DYLIB = 0xc
	LC_ID_DYLIB = 0xd
	LC_LOAD_DYLINKER = 0xe
	LC_ID_DYLINKER = 0xf
	LC_PREBOUND_DYLIB = 0x10
	LC_ROUTINES = 0x11
	LC_SUB_FRAMEWORK = 0x12
	LC_SUB_UMBRELLA = 0x13
	LC_SUB_CLIENT = 0x14
	LC_SUB_LIBRARY = 0x15
	LC_TWOLEVEL_HINTS = 0x16
	LC_PREBIND_CKSUM = 0x17
	LC_LOAD_WEAK_DYLIB = (0x18 | LC_REQ_DYLD)
	LC_SEGMENT_64 = 0x19
	LC_ROUTINES_64 = 0x1a
	LC_UUID = 0x1b
	LC_RPATH = (0x1c | LC_REQ_DYLD)
	LC_CODE_SIGNATURE = 0x1d
	LC_SEGMENT_SPLIT_INFO = 0x1e
	LC_REEXPORT_DYLIB = (0x1f | LC_REQ_DYLD)
	LC_LAZY_LOAD_DYLIB = 0x20
	LC_ENCRYPTION_INFO = 0x21
	LC_DYLD_INFO = 0x22
	LC_DYLD_INFO_ONLY = (0x22 | LC_REQ_DYLD)
	LC_LOAD_UPWARD_DYLIB = (0x23 | LC_REQ_DYLD)
	LC_VERSION_MIN_MACOSX = 0x24
	LC_VERSION_MIN_IPHONEOS = 0x25
	LC_FUNCTION_STARTS = 0x26
	LC_DYLD_ENVIRONMENT = 0x27
	LC_MAIN = (0x28 | LC_REQ_DYLD)
	LC_DATA_IN_CODE = 0x29
	LC_SOURCE_VERSION = 0x2a
	LC_DYLIB_CODE_SIGN_DRS = 0x2b
	LC_ENCRYPTION_INFO_64 = 0x2c
	LC_LINKER_OPTION = 0x2d
	LC_LINKER_OPTIMIZATION_HINT = 0x2e

	LOAD_COMMANDS = {
		LC_SEGMENT => "LC_SEGMENT",
		LC_SYMTAB => "LC_SYMTAB",
		LC_SYMSEC => "LC_SYMSEC",
		LC_THREAD => "LC_THREAD",
		LC_UNIXTHREAD => "LC_UNIXTHREAD",
		LC_LOADFVMLIB => "LC_LOADFVMLIB",
		LC_IDFVMLIB => "LC_IDFVMLIB",
		LC_IDENT => "LC_IDENT",
		LC_FVMFILE => "LC_FVMFILE",
		LC_PREPAGE => "LC_PREPAGE",
		LC_DSYMTAB => "LC_DSYMTAB",
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

	def self.magic?(num)
		num == FAT_MAGIC || num == FAT_CIGAM || num == MH_MAGIC ||
		num == MH_CIGAM || num == MH_MAGIC_64 || num == MH_CIGAM_64
	end

	def self.fat_magic?(num)
		num == FAT_MAGIC || num == FAT_CIGAM
	end

	def self.magic32?(num)
		num == MH_MAGIC || num == MH_CIGAM
	end

	def self.magic64?(num)
		num == MH_MAGIC_64 || num == MH_CIGAM_64
	end
end
