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

			# these are going to vary by arch in the fat file
			# assert_equal MachO::MH_CIGAM_64, macho.magic
			# assert_equal "MH_CIGAM_64", macho.magic_string

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
