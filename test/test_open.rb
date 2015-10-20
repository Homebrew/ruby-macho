require 'minitest/autorun'
require 'macho'

class MachOOpenTest < Minitest::Test
	def test_open
		file = MachO.open("test/bin/thin.dylib")

		assert file.is_a? MachO::MachOFile

		file = MachO.open("test/bin/fat.dylib")

		assert file.is_a? MachO::FatFile
	end
end
