module MachO
	# big-endian fat magic
	FAT_MAGIC = 0xcafebabe

	# little-endian fat magic
	FAT_CIGAM = 0xbebafeca

	# 32-bit big-endian magic
	MH_MAGIC = 0xfeedface

	# 32-bit little-endian magic
	MH_CIGAM = 0xcefaedfe

	# 64-bit big-endian magic
	MH_MAGIC_64 = 0xfeedfacf

	# 64-bit little-endian magic
	MH_CIGAM_64 = 0xcffaedfe

	# association of magic numbers to string representations
	MH_MAGICS = {
		FAT_MAGIC => "FAT_MAGIC",
		FAT_CIGAM => "FAT_CIGAM",
		MH_MAGIC => "MH_MAGIC",
		MH_CIGAM => "MH_CIGAM",
		MH_MAGIC_64 => "MH_MAGIC_64",
		MH_CIGAM_64 => "MH_CIGAM_64"
	}

	# mask for CPUs with 64-bit architectures (when running a 64-bit ABI?)
	CPU_ARCH_ABI64 = 0x01000000

	# any CPU (unused?)
	CPU_TYPE_ANY = -1

	# x86 compatible CPUs
	CPU_TYPE_X86 = 0x07

	# i386 and later compatible CPUs
	CPU_TYPE_I386 = CPU_TYPE_X86

	# x86_64 (AMD64) compatible CPUs
	CPU_TYPE_X86_64 = (CPU_TYPE_X86 | CPU_ARCH_ABI64)

	# PowerPC compatible CPUs (7400 series?)
	CPU_TYPE_POWERPC = 0x24

	# PowerPC64 compatible CPUs (970 series?)
	CPU_TYPE_POWERPC64 = (CPU_TYPE_POWERPC | CPU_ARCH_ABI64)

	# association of cpu types to string representations
	CPU_TYPES = {
		CPU_TYPE_ANY => "CPU_TYPE_ANY",
		CPU_TYPE_X86 => "CPU_TYPE_X86",
		CPU_TYPE_I386 => "CPU_TYPE_I386",
		CPU_TYPE_X86_64 => "CPU_TYPE_X86_64",
		CPU_TYPE_POWERPC => "CPU_TYPE_POWERPC",
		CPU_TYPE_POWERPC64 => "CPU_TYPE_POWERPC64"
	}

	# mask for CPU subtype capabilities
	CPU_SUBTYPE_MASK = 0xff000000

	# 64-bit libraries (undocumented!)
	# @see http://llvm.org/docs/doxygen/html/Support_2MachO_8h_source.html
	CPU_SUBTYPE_LIB64 = 0x80000000

	# all x86-type CPUs
	CPU_SUBTYPE_X86_ALL = 3

	# all x86-type CPUs (what makes this different from CPU_SUBTYPE_X86_ALL?)
	CPU_SUBTYPE_X86_ARCH1 = 4

	# association of cpu subtypes to string representations
	CPU_SUBTYPES = {
		CPU_SUBTYPE_X86_ALL => "CPU_SUBTYPE_X86_ALL",
		CPU_SUBTYPE_X86_ARCH1 => "CPU_SUBTYPE_X86_ARCH1"
	}

	# relocatable object file
	MH_OBJECT = 0x1

	# demand paged executable file
	MH_EXECUTE = 0x2

	# fixed VM shared library file
	MH_FVMLIB = 0x3

	# core dump file
	MH_CORE = 0x4

	# preloaded executable file
	MH_PRELOAD = 0x5

	# dynamically bound shared library
	MH_DYLIB = 0x6

	# dynamic link editor
	MH_DYLINKER = 0x7

	# dynamically bound bundle file
	MH_BUNDLE = 0x8

	# shared library stub for static linking only, no section contents
	MH_DYLIB_STUB = 0x9

	# companion file with only debug sections
	MH_DSYM = 0xa

	# x86_64 kexts
	MH_KEXT_BUNDLE = 0xb

	# association of filetypes to string representations
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

	# the object file has no undefined references (flag)
	MH_NOUNDEFS = 0x1

	# the object file is the output of an incremental link against a base file (flag)
	MH_INCRLINK = 0x2

	# the object file is input for the dynamic linker and can't be staticly link edited again (flag)
	MH_DYLDLINK = 0x4

	# the object file's undefined references are bound by the dynamic linker when loaded (flag)
	MH_BINDATLOAD = 0x8

	# the file has its dynamic undefined references prebound (flag)
	MH_PREBOUND = 0x10

	# the file has its read-only and read-write segments split (flag)
	MH_SPLIT_SEGS = 0x20

	# the shared library init routine is to be run lazily via catching memory faults to its writeable segments (obsolete) (flag)
	MH_LAZY_INIT = 0x40

	# the image is using two-level name space bindings (flag)
	MH_TWOLEVEL = 0x80

	# the executable is forcing all images to use flat name space bindings (flag)
	MH_FORCE_FLAT = 0x100

	# this umbrella guarantees no multiple defintions of symbols in its sub-images so the two-level namespace hints can always be used (flag)
	MH_NOMULTIDEFS = 0x200

	# do not have dyld notify the prebinding agent about this executable (flag)
	MH_NOPREFIXBINDING = 0x400

	# the binary is not prebound but can have its prebinding redone. only used when MH_PREBOUND is not set (flag)
	MH_PREBINDABLE = 0x800

	# indicates that this binary binds to all two-level namespace modules of its dependent libraries. only used when MH_PREBINDABLE and MH_TWOLEVEL are both set (flag)
	MH_ALLMODSBOUND = 0x1000

	# safe to divide up the sections into sub-sections via symbols for dead code stripping (flag)
	MH_SUBSECTIONS_VIA_SYMBOLS = 0x2000

	# the binary has been canonicalized via the unprebind operation (flag)
	MH_CANONICAL = 0x4000

	# the final linked image contains external weak symbols (flag)
	MH_WEAK_DEFINES = 0x8000

	# the final linked image uses weak symbols (flag)
	MH_BINDS_TO_WEAK = 0x10000

	# When this bit is set, all stacks in the task will be given stack execution privilege.  Only used in MH_EXECUTE filetypes (flag)
	MH_ALLOW_STACK_EXECUTION = 0x20000

	# When this bit is set, the binary declares it is safe for use in processes with uid zero (flag)
	MH_ROOT_SAFE = 0x40000

	# When this bit is set, the binary declares it is safe for use in processes when issetugid() is true (flag)
	MH_SETUID_SAFE = 0x80000

	# When this bit is set on a dylib, the static linker does not need to examine dependent dylibs to see if any are re-exported (flag)
	MH_NO_REEXPORTED_DYLIBS = 0x100000

	# When this bit is set, the OS will load the main executable at a random address.  Only used in MH_EXECUTE filetypes (flag)
	MH_PIE = 0x200000

	# Only for use on dylibs.  When linking against a dylib that has this bit set, the static linker will automatically not create a LC_LOAD_DYLIB load command to the dylib if no symbols are being referenced from the dylib (flag)
	MH_DEAD_STRIPPABLE_DYLIB = 0x400000

	# Contains a section of type S_THREAD_LOCAL_VARIABLES (flag)
	MH_HAS_TLV_DESCRIPTORS = 0x800000

	# When this bit is set, the OS will run the main executable with a non-executable heap even on platforms (e.g. i386) that don't require it. Only used in MH_EXECUTE filetypes (flag)
	MH_NO_HEAP_EXECUTION = 0x1000000

	# The code was linked for use in an application extension (flag)
	MH_APP_EXTENSION_SAFE = 0x02000000

	# association of mach header flags to string representations
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

	# Fat binary header structure
	class FatHeader < MachOStructure
		attr_reader :magic
		attr_reader :nfat_arch # number of FatArchs that follow

		@format = "VV"
		@sizeof = 8

		def initialize(magic, nfat_arch)
			@magic = magic
			@nfat_arch = nfat_arch
		end
	end

	# Fat binary header architecture structure
	class FatArch < MachOStructure
		attr_reader :cputype
		attr_reader :cpusubtype
		attr_reader :offset
		attr_reader :size
		attr_reader :align

		@format = "VVVVV"
		@sizeof = 20

		def initialize(cputype, cpusubtype, offset, size, align)
			@cputype = cputype
			@cpusubtype = cpusubtype
			@offset = offset
			@size = size
			@align = align
		end
	end

	# 32-bit Mach-O file header structure
	class MachHeader < MachOStructure
		attr_reader :magic
		attr_reader :cputype
		attr_reader :cpusubtype
		attr_reader :filetype
		attr_reader :ncmds
		attr_reader :sizeofcmds
		attr_reader :flags

		@format = "VVVVVVV"
		@sizeof = 28

		def initialize(magic, cputype, cpusubtype, filetype, ncmds, sizeofcmds,
				flags)
			@magic = magic
			@cputype = cputype
			@cpusubtype = cpusubtype
			@filetype = filetype
			@ncmds = ncmds
			@sizeofcmds = sizeofcmds
			@flags = flags
		end

		# @example
		#  puts "this mach-o has position-independent execution" if header.flag?(MH_PIE)
		# @param flag [Fixnum] a mach header flag constant
		# @return [Boolean] true if `flag` is present in the header's flag section
		def flag?(flag)
			flags & flag == flag
		end
	end

	# 64-bit Mach-O file header structure
	class MachHeader64 < MachOStructure
		attr_reader :magic
		attr_reader :cputype
		attr_reader :cpusubtype
		attr_reader :filetype
		attr_reader :ncmds
		attr_reader :sizeofcmds
		attr_reader :flags
		attr_reader :reserved

		@format = "VVVVVVVV"
		@sizeof = 32

		def initialize(magic, cputype, cpusubtype, filetype, ncmds, sizeofcmds,
				flags, reserved)
			@magic = magic
			@cputype = cputype
			@cpusubtype = cpusubtype
			@filetype = filetype
			@ncmds = ncmds
			@sizeofcmds = sizeofcmds
			@flags = flags
			@reserved = reserved
		end

		# @example
		#  puts "this mach-o has position-independent execution" if header.flag?(MH_PIE)
		# @param flag [Fixnum] a mach header flag constant
		# @return [Boolean] true if `flag` is present in the header's flag section
		def flag?(flag)
			flags & flag == flag
		end
	end
end
