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

	def test_dylib
		file = MachO::MachOFile.new("test/bin/thin.dylib")

		# a file can only be ONE of these
		assert !file.executable?
		assert file.dylib?
		assert !file.bundle?

		assert_equal MachO::MH_CIGAM_64, file.magic
		assert_equal "MH_CIGAM_64", file.magic_string
		assert_equal "MH_DYLIB", file.filetype
		assert file.cputype
		assert file.cpusubtype
		assert file.ncmds
		assert file.sizeofcmds
		assert file.flags

		# it's a dylib, so it *must* have a dylib id
		assert file.dylib_id

		# changing the dylib id should work
		old_id = file.dylib_id
		file.dylib_id = "testing"
		assert_equal "testing", file.dylib_id

		# change it back within the same instance
		file.dylib_id = old_id
		assert_equal old_id, file.dylib_id

		assert file.segments.size > 0
		assert file.linked_dylibs.size > 0

		really_big_id = "x" * 2048

		# test failsafe for excessively large IDs (w/ no special linking)
		assert_raises MachO::HeaderPadError do
			file.dylib_id = really_big_id
		end
	end

	def test_bundle
		file = MachO::MachOFile.new("test/bin/attr.so")

		# a file can only be ONE of these
		assert !file.executable?
		assert !file.dylib?
		assert file.bundle?

		assert_equal MachO::MH_CIGAM_64, file.magic
		assert_equal "MH_CIGAM_64", file.magic_string
		assert_equal "MH_BUNDLE", file.filetype
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
