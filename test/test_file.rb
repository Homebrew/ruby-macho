require 'minitest/autorun'
require 'macho'

class MachOFileTest < Minitest::Test
	def test_executable
		file = MachO::MachOFile.new("test/bin/as.bin")

		# a file can only be ONE of these
		assert file.executable?
		assert !file.dylib?
		assert !file.bundle?

		assert_equal MachO::MH_CIGAM_64, file.magic
		assert_equal "MH_CIGAM_64", file.magic_string
		assert_equal "MH_EXECUTE", file.filetype
		assert file.cputype
		assert file.cpusubtype
		assert file.ncmds
		assert file.sizeofcmds
		assert file.flags

		# it's not a dylib, so it has no dylib id
		assert_nil file.dylib_id

		assert file.segments.size > 0
		assert file.linked_dylibs.size > 0
	end
end
