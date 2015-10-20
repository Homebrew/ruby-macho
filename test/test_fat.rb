require 'minitest/autorun'
require 'macho'

class FatFileTest < Minitest::Test
	def test_dylib
		file = MachO::FatFile.new("test/bin/fat.dylib")

		file.machos.each do |macho|
			# a file can only be ONE of these
			assert !macho.executable?
			assert macho.dylib?
			assert !macho.bundle?

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
end
