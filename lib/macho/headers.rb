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

	# TODO: declare values for flags in MachHeader/MachHeader64

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
	end
end
