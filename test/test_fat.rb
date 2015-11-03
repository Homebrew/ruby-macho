require "minitest/autorun"
require "macho"
require "#{File.dirname(__FILE__)}/helpers"

class FatFileTest < Minitest::Test
	include Helpers

	def test_fat_header
		file = MachO::FatFile.new(TEST_FAT_EXE)
		header = file.header

		assert header
		assert_kind_of MachO::FatHeader, header
		assert_kind_of Fixnum, header.magic
		assert_kind_of Fixnum, header.nfat_arch
	end

	def test_fat_archs
		file = MachO::FatFile.new(TEST_FAT_DYLIB)
		archs = file.fat_archs

		assert archs
		assert_kind_of Array, archs

		archs.each do |arch|
			assert arch
			assert_kind_of MachO::FatArch, arch
			assert_kind_of Fixnum, arch.cputype
			assert_kind_of Fixnum, arch.cpusubtype
			assert_kind_of Fixnum, arch.offset
			assert_kind_of Fixnum, arch.size
			assert_kind_of Fixnum, arch.align
		end
	end

	def test_executable
		file = MachO::FatFile.new(TEST_FAT_EXE)
		checks = filechecks(except = :executable?)

		assert file.executable?
		checks.each do |check|
			refute file.send(check)
		end

		file.machos.each do |macho|
			# a file can only be ONE of these
			assert macho.executable?
			checks.each do |check|
				refute macho.send(check)
			end

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
		file = MachO::FatFile.new(TEST_FAT_DYLIB)
		checks = filechecks(except = :dylib?)

		assert file.dylib?
		checks.each do |check|
			refute file.send(check)
		end

		file.machos.each do |macho|
			# a file can only be ONE of these
			assert macho.dylib?
			checks.each do |check|
				refute macho.send(check)
			end

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
		file = MachO::FatFile.new(TEST_FAT_BUNDLE)
		checks = filechecks(except = :bundle?)

		assert file.bundle?
		checks.each do |check|
			refute file.send(check)
		end

		file.machos.each do |macho|
			# a file can only be ONE of these
			assert macho.bundle?
			checks.each do |check|
				refute macho.send(check)
			end

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

	def test_extract_macho
		file = MachO::FatFile.new(TEST_FAT_EXE)

		assert file.machos.size == 2

		macho1 = file.extract("CPU_TYPE_I386")
		macho2 = file.extract("CPU_TYPE_X86_64")
		not_real = file.extract("CPU_TYPE_NONEXISTENT")

		assert macho1
		assert macho2
		assert_nil not_real

		assert_equal file.machos[0].serialize, macho1.serialize
		assert_equal file.machos[1].serialize, macho2.serialize

		# write the extracted mach-os to disk
		macho1.write("test/bin/extracted_macho1.bin")
		macho2.write("test/bin/extracted_macho2.bin")

		# load them back to ensure they're intact/uncorrupted
		mfile1 = MachO::MachOFile.new("test/bin/extracted_macho1.bin")
		mfile2 = MachO::MachOFile.new("test/bin/extracted_macho2.bin")

		assert_equal file.machos[0].serialize, mfile1.serialize
		assert_equal file.machos[1].serialize, mfile2.serialize
	ensure
		File.delete("test/bin/extracted_macho1.bin")
		File.delete("test/bin/extracted_macho2.bin")
	end

	def test_change_dylib_id
		pass
	end

	def test_change_install_name
		pass
	end
end
