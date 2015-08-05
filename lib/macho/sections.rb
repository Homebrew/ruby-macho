module MachO
	# the flags field of a section has two parts: a type and attributes
	SECTION_TYPE = 0x000000ff # type mask
	SECTION_ATTRIBUTES = 0xffffff00 # attributes mask
	SECTION_ATTRIBUTES_USR = 0xff000000 # user settable attributes mask
	SECTION_ATTRIBUTES_SYS = 0x00ffff00 # system settable attributes mask

	# section types for the flags field
	S_REGULAR = 0x0
	S_ZEROFILL = 0x1
	S_CSTRING_LITERALS = 0x2
	S_4BYTE_LITERALS = 0x3
	S_8BYTE_LITERALS = 0x4
	S_LITERAL_POINTERS = 0x5
	S_NON_LAZY_SYMBOL_POINTERS = 0x6
	S_LAZY_SYMBOL_POINTERS = 0x7
	S_SYMBOL_STUBS = 0x8
	S_MOD_INIT_FUNC_POINTERS = 0x9
	S_MOD_TERM_FUNC_POINTERS = 0xa
	S_COALESCED = 0xb
	S_GB_ZEROFILE = 0xc
	S_INTERPOSING = 0xd
	S_16BYTE_LITERALS = 0xe
	S_DTRACE_DOF = 0xf
	S_LAZY_DYLIB_SYMBOL_POINTERS = 0x10
	S_THREAD_LOCAL_REGULAR = 0x11
	S_THREAD_LOCAL_ZEROFILL = 0x12
	S_THREAD_LOCAL_VARIABLES = 0x13
	S_THREAD_LOCAL_VARIABLE_POINTERS = 0x14
	S_THREAD_LOCAL_INIT_FUNCTION_POINTERS = 0x15

	# section attributes for the flags field
	S_ATTR_PURE_INSTRUCTIONS = 0x80000000
	S_ATTR_NO_TOC = 0x40000000
	S_ATTR_STRIP_STATIC_SYMS = 0x20000000
	S_ATTR_NO_DEAD_STRIP = 0x10000000
	S_ATTR_LIVE_SUPPORT = 0x08000000
	S_ATTR_SELF_MODIFYING_CODE = 0x04000000
	S_ATTR_DEBUG = 0x02000000
	S_ATTR_SOME_INSTRUCTIONS = 0x00000400
	S_ATTR_EXT_RELOC = 0x00000200
	S_ATTR_LOC_RELOC = 0x00000100

	# currently known section names
	# we don't use these anywhere right now, but they're good to have
	SECT_TEXT = "__text"
	SECT_FVMLIB_INIT0 = "__fvmlib_init0"
	SECT_FVMLIB_INIT1 = "__fvmlib_init1"
	SECT_DATA = "__data"
	SECT_BSS = "__bss"
	SECT_COMMON = "__common"
	SECT_OBJC_SYMBOLS = "__symbol_table"
	SECT_OBJC_MODULES = "__module_info"
	SECT_OBJC_STRINGS = "__selector_strs"
	SECT_OBJC_REFS = "__selector_refs"
	SECT_ICON_HEADER = "__header"
	SECT_ICON_TIFF = "__tiff"

	class Section < MachOStructure
		attr_reader :sectname, :segname, :addr, :size, :offset, :align, :reloff
		attr_reader :nreloc, :flags, :reserved1, :reserved2

		@format = "a16a16VVVVVVVVV"
		@sizeof = 68

		def initialize(sectname, segname, addr, size, offset, align, reloff,
				nreloc, flags, reserved1, reserved2)
			@sectname = sectname
			@segname = segname
			@addr = addr
			@size = size
			@offset = offset
			@align = align
			@reloff = reloff
			@nreloc = nreloc
			@flags = flags
			@reserved1 = reserved1
			@reserved2 = reserved2
		end

		def section_name
			@sectname.delete("\x00")
		end

		def segment_name
			@segname.delete("\x00")
		end

		def flag?(flag)
			flags & flag == flag
		end
	end

	class Section64 < MachOStructure
		attr_reader :sectname, :segname, :addr, :size, :offset, :align, :reloff
		attr_reader :nreloc, :flags, :reserved1, :reserved2, :reserved3

		@format = "a16a16QQVVVVVVVV"
		@sizeof = 80

		def initialize(sectname, segname, addr, size, offset, align, reloff,
				nreloc, flags, reserved1, reserved2, reserved3)
			@sectname = sectname
			@segname = segname
			@addr = addr
			@size = size
			@offset = offset
			@align = align
			@reloff = reloff
			@nreloc = nreloc
			@flags = flags
			@reserved1 = reserved1
			@reserved2 = reserved2
			@reserved3 = reserved3
		end

		def section_name
			@sectname.delete("\x00")
		end

		def segment_name
			@segname.delete("\x00")
		end

		def flag?(flag)
			flags & flag == flag
		end
	end
end