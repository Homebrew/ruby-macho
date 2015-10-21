require 'minitest/autorun'
require 'macho'

class FatFileTest < Minitest::Test
	def test_executable
		file = MachO::FatFile.new("test/bin/fathello.bin")

		file.machos.each do |macho|
			# a file can only be ONE of these
			assert macho.executable?
			refute macho.dylib?
			refute macho.bundle?

			assert MachO.magic?(macho.magic)

			assert_equal "MH_EXECUTE", macho.filetype
			assert macho.cputype
			assert macho.cpusubtype
			assert macho.ncmds
			assert macho.sizeofcmds
			assert macho.flags
			assert_nil macho.dylib_id
		end
	end

	def test_dylib
		file = MachO::FatFile.new("test/bin/libfathello.dylib")

		file.machos.each do |macho|
			# a file can only be ONE of these
			refute macho.executable?
			assert macho.dylib?
			refute macho.bundle?

			assert MachO.magic?(macho.magic)

			assert_equal "MH_DYLIB", macho.filetype
			assert macho.cputype
			assert macho.cpusubtype
			assert macho.ncmds
			assert macho.sizeofcmds
			assert macho.flags
			assert macho.dylib_id
		end

		assert file.linked_dylibs
	end

	def test_bundle
		file = MachO::FatFile.new("test/bin/fathellobundle.so")

		file.machos.each do |macho|
			# a file can only be ONE of these
			refute macho.executable?
			refute macho.dylib?
			assert macho.bundle?

			assert MachO.magic?(macho.magic)

			assert_equal "MH_BUNDLE", macho.filetype
			assert macho.cputype
			assert macho.cpusubtype
			assert macho.ncmds
			assert macho.sizeofcmds
			assert macho.flags
			assert_nil macho.dylib_id
		end

		assert file.linked_dylibs
	end
end
