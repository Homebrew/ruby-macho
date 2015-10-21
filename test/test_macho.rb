require 'minitest/autorun'
require 'digest/sha1'
require 'macho'

class MachOFileTest < Minitest::Test
	def equal_sha1_hashes(file1, file2)
		digest1 = Digest::SHA1.file(file1).to_s
		digest2 = Digest::SHA1.file(file2).to_s

		digest1 == digest2
	end

	def test_executable
		file = MachO::MachOFile.new("test/bin/hello.bin")

		# a file can only be ONE of these
		assert file.executable?
		refute file.dylib?
		refute file.bundle?

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
		refute file.executable?
		assert file.dylib?
		refute file.bundle?

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

		assert file.segments.size > 0
		assert file.linked_dylibs.size > 0
	end

	def test_bundle
		file = MachO::MachOFile.new("test/bin/attr.so")

		# a file can only be ONE of these
		refute file.executable?
		refute file.dylib?
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

	def test_change_dylib_id
		file = MachO::MachOFile.new("test/bin/thin.dylib")

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

		# TODO: compare actual and expected file hashes
	end

	def test_change_install_name
		file = MachO::MachOFile.new("test/bin/hello.bin")

		dylibs = file.linked_dylibs

		# there should be at least one dylib linked to the binary
		refute_empty dylibs

		file.change_install_name(dylibs[0], "test")
		new_dylibs = file.linked_dylibs

		# the new dylib name should reflect the changes we've made
		assert_equal "test", new_dylibs[0]
		refute_equal dylibs[0], new_dylibs[0]

		file.write("test/bin/hello_actual.bin")

		# compare actual and expected file hashes, to ensure file correctness
		assert equal_sha1_hashes("test/bin/hello_actual.bin", "test/bin/hello_expected.bin")
	ensure
		File.delete("test/bin/hello_actual.bin")
	end
end
