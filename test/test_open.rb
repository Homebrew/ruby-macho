require 'minitest/autorun'
require 'macho'

class MachOOpenTest < Minitest::Test
	def test_open
		file = MachO.open("test/bin/libhello.dylib")

		assert_kind_of MachO::MachOFile, file

		file = MachO.open("test/bin/libfathello.dylib")

		assert_kind_of MachO::FatFile, file
	end
end
