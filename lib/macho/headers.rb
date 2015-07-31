module MachO
	# magic numbers used in Mach-O files
	FAT_MAGIC = 0xcafebabe # big-endian fat magic
	FAT_CIGAM = 0xbebafeca # little-endian fat magic
	MH_MAGIC = 0xfeedface # 32-bit big-endian magic
	MH_CIGAM = 0xcefaedfe # 32-bit little-endian magic
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
	CPU_TYPE_POWERPC = 0x24
	CPU_TYPE_POWERPC64 = (CPU_TYPE_POWERPC | CPU_ARCH_ABI64)

	CPU_TYPES = {
		CPU_TYPE_ANY => "CPU_TYPE_ANY",
		CPU_TYPE_X86 => "CPU_TYPE_X86",
		CPU_TYPE_I386 => "CPU_TYPE_I386",
		CPU_TYPE_X86_64 => "CPU_TYPE_X86_64",
		CPU_TYPE_POWERPC => "CPU_TYPE_POWERPC",
		CPU_TYPE_POWERPC64 => "CPU_TYPE_POWERPC64"
	}

	# capability bits used in the definition of cpusubtype
	# http://llvm.org/docs/doxygen/html/Support_2MachO_8h_source.html
	CPU_SUBTYPE_MASK = 0xff000000
	CPU_SUBTYPE_LIB64 = 0x80000000

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

	# values for flags field in MachHeader/MachHeader64
	MH_NOUNDEFS = 0x1
	MH_INCRLINK = 0x2
	MH_DYLDLINK = 0x4
	MH_BINDATLOAD = 0x8
	MH_PREBOUND = 0x10
	MH_SPLIT_SEGS = 0x20
	MH_LAZY_INIT = 0x40
	MH_TWOLEVEL = 0x80
	MH_FORCE_FLAT = 0x100
	MH_NOMULTIDEFS = 0x200
	MH_NOPREFIXBINDING = 0x400
	MH_PREBINDABLE = 0x800
	MH_ALLMODSBOUND = 0x1000
	MH_SUBSECTIONS_VIA_SYMBOLS = 0x2000
	MH_CANONICAL = 0x4000
	MH_WEAK_DEFINES = 0x8000
	MH_BINDS_TO_WEAK = 0x10000
	MH_ALLOW_STACK_EXECUTION = 0x20000
	MH_ROOT_SAFE = 0x40000
	MH_SETUID_SAFE = 0x80000
	MH_NO_REEXPORTED_DYLIBS = 0x100000
	MH_PIE = 0x200000
	MH_DEAD_STRIPPABLE_DYLIB = 0x400000
	MH_HAS_TLV_DESCRIPTORS = 0x800000
	MH_NO_HEAP_EXECUTION = 0x1000000
	MH_APP_EXTENSION_SAFE = 0x02000000

	MH_FLAGS = {
		MH_NOUNDEFS => "MH_NOUNDEFS",
		MH_INCRLINK => "MH_INCRLINK",
		MH_DYLDLINK => "MH_DYLDLINK",
		MH_BINDATLOAD => "MH_BINDATLOAD",
		MH_PREBOUND => "MH_PREBOUND",
		MH_SPLIT_SEGS => "MH_SPLIT_SEGS",
		MH_LAZY_INIT => "MH_LAZY_INIT",
		MH_TWOLEVEL => "MH_TWOLEVEL",
		MH_FORCE_FLAT => "MH_FORCE_FLAT",
		MH_NOMULTIDEFS => "MH_NOMULTIDEFS",
		MH_NOPREFIXBINDING => "MH_NOPREFIXBINDING",
		MH_PREBINDABLE => "MH_PREBINDABLE",
		MH_ALLMODSBOUND => "MH_ALLMODSBOUND",
		MH_SUBSECTIONS_VIA_SYMBOLS => "MH_SUBSECTIONS_VIA_SYMBOLS",
		MH_CANONICAL => "MH_CANONICAL",
		MH_WEAK_DEFINES => "MH_WEAK_DEFINES",
		MH_BINDS_TO_WEAK => "MH_BINDS_TO_WEAK",
		MH_ALLOW_STACK_EXECUTION => "MH_ALLOW_STACK_EXECUTION",
		MH_ROOT_SAFE => "MH_ROOT_SAFE",
		MH_SETUID_SAFE => "MH_SETUID_SAFE",
		MH_NO_REEXPORTED_DYLIBS => "MH_NO_REEXPORTED_DYLIBS",
		MH_PIE => "MH_PIE",
		MH_DEAD_STRIPPABLE_DYLIB => "MH_DEAD_STRIPPABLE_DYLIB",
		MH_HAS_TLV_DESCRIPTORS => "MH_HAS_TLV_DESCRIPTORS",
		MH_NO_HEAP_EXECUTION => "MH_NO_HEAP_EXECUTION",
		MH_APP_EXTENSION_SAFE => "MH_APP_EXTENSION_SAFE"
	}

	# 'Fat' binaries envelop Mach-O binaries so include them for completeness,
	# Fat binary header structure
	class FatHeader < CStruct
		uint32 :magic
		uint32 :nfat_arch # number of FatArchs that follow
	end

	# Fat binary header architecture structure
	class FatArch < CStruct
		int32 :cputype
		int32 :cpusubtype
		uint32 :offset
		uint32 :size
		uint32 :align
	end

	# 32-bit Mach-O file header structure
	class MachHeader < CStruct
		uint32 :magic
		int32 :cputype
		int32 :cpusubtype
		uint32 :filetype
		uint32 :ncmds
		uint32 :sizeofcmds
		uint32 :flags

		def flag?(flag)
			flags & flag == flag
		end
	end

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

		def flag?(flag)
			flags & flag == flag
		end
	end
end
