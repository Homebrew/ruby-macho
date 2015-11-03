require "minitest/autorun"
require "macho"
require "#{File.dirname(__FILE__)}/helpers"

class MachOFileTest < Minitest::Test
	include Helpers

	def test_load_commands
		file = MachO::MachOFile.new(TEST_EXE)

		file.load_commands.each do |lc|
			assert lc
			assert_equal MachO::LoadCommand, lc.class.superclass
			assert_kind_of Fixnum, lc.offset
			assert_kind_of Fixnum, lc.cmd
			assert_kind_of Fixnum, lc.cmdsize
			assert_kind_of String, lc.to_s
			assert_kind_of Symbol, lc.type
			assert_kind_of Symbol, lc.to_sym
		end
	end

	def test_mach_header
		file = MachO::MachOFile.new(TEST_DYLIB)
		header = file.header

		assert header
		assert_kind_of MachO::MachHeader, header if file.magic32?
		assert_kind_of MachO::MachHeader64, header if file.magic64?
		assert_kind_of Fixnum, header.magic
		assert_kind_of Fixnum, header.cputype
		assert_kind_of Fixnum, header.cpusubtype
		assert_kind_of Fixnum, header.filetype
		assert_kind_of Fixnum, header.ncmds
		assert_kind_of Fixnum, header.sizeofcmds
		assert_kind_of Fixnum, header.flags
	end

	def test_executable
		file = MachO::MachOFile.new(TEST_EXE)

		# a file can only be ONE of these
		assert file.executable?
		checks = filechecks(except = :executable?)
		checks.each do |check|
			refute file.send(check)
		end

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
		file = MachO::MachOFile.new(TEST_DYLIB)

		# a file can only be ONE of these
		assert file.dylib?
		checks = filechecks(except = :dylib?)
		checks.each do |check|
			refute file.send(check)
		end

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
		file = MachO::MachOFile.new(TEST_BUNDLE)

		# a file can only be ONE of these
		assert file.bundle?
		checks = filechecks(except = :bundle?)
		checks.each do |check|
			refute file.send(check)
		end

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
		file = MachO::MachOFile.new(TEST_DYLIB)

		# changing the dylib id should work
		old_id = file.dylib_id
		file.dylib_id = "testing"
		assert_equal "testing", file.dylib_id

		# change it back within the same instance
		file.dylib_id = old_id
		assert_equal old_id, file.dylib_id

		assert file.segments.size > 0
		assert file.linked_dylibs.size > 0

		really_big_id = "x" * 4096

		# test failsafe for excessively large IDs (w/ no special linking)
		assert_raises MachO::HeaderPadError do
			file.dylib_id = really_big_id
		end

		file.dylib_id = "test"

		file.write("test/bin/libhello_actual.dylib")

		assert equal_sha1_hashes("test/bin/libhello_actual.dylib", "test/bin/libhello_expected.dylib")
	ensure
		File.delete("test/bin/libhello_actual.dylib")
	end

	def test_change_install_name
		file = MachO::MachOFile.new(TEST_EXE)

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
