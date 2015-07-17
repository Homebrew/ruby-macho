require "./lib/cstruct.rb"
require "./lib/macho/file"

# http://www.opensource.apple.com/source/cctools/cctools-870/include/mach-o/loader.h
# http://www.opensource.apple.com/source/cctools/cctools-870/include/mach-o/fat.h

module MachO
	# 'Fat' binaries envelop Mach-O binaries, so include them for completeness
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

	# values for filetype in MachHeader/MachHeader64
	MH_OBJECT = 0x1			# relocatable object file
	MH_EXECUTE = 0x2		# demand paged executable file
	MH_FVMLIB = 0x3			# fixed VM shared library file
	MH_CORE = 0x4			# core file
	MH_PRELOAD = 0x5		# preloaded executable file
	MH_DYLIB = 0x6			# dynamically bound shared library
	MH_DYLINKER = 0x7		# dynamic link editor
	MH_BUNDLE = 0x8			# dynamically bound bundle file
	MH_DYLIB_STUB = 0x9		# shared library stub for static linking only, no
							# section contents
	MH_DSYM = 0xa			# companion file with only debug sections
	MH_KEXT_BUNDLE = 0xb	# x86_64 lexts

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
	LC_SECMENT = 0x1
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

	# 32-bit Mach-O segment command structure
	class SegmentCommand < CStruct
		uint32 :cmd
		uint32 :cmdsize
		string :segname, 16
		uint32 :vmaddr
		uint32 :vmsize
		uint32 :fileoff
		uint32 :filesize
		int32 :maxprot
		int32 :initprot
		uint32 :nsects
		uint32 :flags
	end

	# 64-bit Mach-O segment command structure
	class SegmentCommand64 < CStruct
		uint32 :cmd
		uint32 :cmdsize
		string :segname, 16
		uint32 :vmaddr
		uint32 :vmsize
		uint32 :fileoff
		uint32 :filesize
		int32 :maxprot
		int32 :initprot
		uint32 :nsects
		uint32 :flags
	end

	# TODO: declare values for protection, flag fields of SegmentCommand{64}

	# 32-bit Mach-O segment section structure
	class Section < CStruct
		string :sectname, 16
		string :segname, 16
		uint32 :addr
		uint32 :size
		uint32 :offset
		uint32 :align
		uint32 :reloff
		uint32 :nreloc
		uint32 :flags
		uint32 :reserved1
		uint32 :reserved2
	end

	# 64-bit Mach-O segment section structure
	class Section64 < CStruct
		string :sectname, 16
		string :segname, 16
		uint32 :addr
		uint32 :size
		uint32 :offset
		uint32 :align
		uint32 :reloff
		uint32 :nreloc
		uint32 :flags
		uint32 :reserved1
		uint32 :reserved2
		uint32 :reserved3
	end

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
