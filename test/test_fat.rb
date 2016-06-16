require "minitest/autorun"
require "helpers"
require "macho"

class FatFileTest < Minitest::Test
  include Helpers

  def test_nonexistent_file
    assert_raises ArgumentError do
      MachO::FatFile.new("/this/is/a/file/that/cannot/possibly/exist")
    end
  end

  def test_empty_file
    tempfile_with_data("empty_file", "") do |empty_file|
      assert_raises MachO::TruncatedFileError do
        MachO::FatFile.new(empty_file.path)
      end
    end
  end

  def test_truncated_file
    tempfile_with_data("truncated_file", "\xCA\xFE\xBA\xBE\x00\x00") do |truncated_file|
      assert_raises MachO::TruncatedFileError do
        MachO::FatFile.new(truncated_file.path)
      end
    end
  end

  def test_java_classfile
    blob = "\xCA\xFE\xBA\xBE\x00\x00\x00\x33therestofthisfileisnotarealjavaclassfile"
    tempfile_with_data("fake_java_class_file", blob) do |fake_java_class_file|
      assert_raises MachO::JavaClassFileError do
        MachO::FatFile.new(fake_java_class_file.path)
      end
    end
  end

  def test_fat_header
    filenames = FAT_ARCH_PAIRS.map { |a| fixture(a, "hello.bin") }

    filenames.each do |fn|
      file = MachO::FatFile.new(fn)

      header = file.header

      assert header
      assert_kind_of MachO::FatHeader, header
      assert_kind_of Fixnum, header.magic
      assert_kind_of Fixnum, header.nfat_arch
    end
  end

  def test_fat_archs
    filenames = FAT_ARCH_PAIRS.map { |a| fixture(a, "libhello.dylib") }

    filenames.each do |fn|
      file = MachO::FatFile.new(fn)
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
  end

  def test_machos
    filenames = FAT_ARCH_PAIRS.map { |a| fixture(a, "hellobundle.so") }

    filenames.each do |fn|
      file = MachO::FatFile.new(fn)

      machos = file.machos
      assert machos
      assert_kind_of Array, machos

      machos.each do |macho|
        assert macho
        assert_kind_of MachO::MachOFile, macho

        assert macho.serialize
        assert_kind_of String, macho.serialize
      end
    end
  end

  def test_file
    filenames = FAT_ARCH_PAIRS.map { |a| fixture(a, "hello.bin") }

    filenames.each do |fn|
      file = MachO::FatFile.new(fn)

      assert file.serialize
      assert_kind_of String, file.serialize

      assert_kind_of Fixnum, file.magic
      assert_kind_of String, file.magic_string
      assert_kind_of String, file.filetype
    end
  end

  def test_object
    filenames = FAT_ARCH_PAIRS.map { |a| fixture(a, "hello.o") }

    filenames.each do |fn|
      file = MachO::FatFile.new(fn)

      assert file.object?
      filechecks(except = :object?).each do |check|
        refute file.send(check)
      end

      assert_equal "MH_OBJECT", file.filetype
    end
  end

  def test_executable
    filenames = FAT_ARCH_PAIRS.map { |a| fixture(a, "hello.bin") }

    filenames.each do |fn|
      file = MachO::FatFile.new(fn)

      assert file.executable?
      filechecks(except = :executable?).each do |check|
        refute file.send(check)
      end

      assert_equal "MH_EXECUTE", file.filetype
    end
  end

  def test_dylib
    filenames = FAT_ARCH_PAIRS.map { |a| fixture(a, "libhello.dylib") }

    filenames.each do |fn|
      file = MachO::FatFile.new(fn)

      assert file.dylib?
      filechecks(except = :dylib?).each do |check|
        refute file.send(check)
      end

      assert_equal "MH_DYLIB", file.filetype
    end
  end

  def test_extra_dylib
    filenames = FAT_ARCH_PAIRS.map { |a| fixture(a, "libextrahello.dylib") }
    unusual_dylib_lcs = [
      :LC_LOAD_UPWARD_DYLIB,
      :LC_LAZY_LOAD_DYLIB,
      :LC_LOAD_WEAK_DYLIB,
      :LC_REEXPORT_DYLIB
    ]

    filenames.each do |fn|
      file = MachO::FatFile.new(fn)

      assert file.dylib?

      file.machos.each do |macho|
        # make sure we can read more unusual dylib load commands
        unusual_dylib_lcs.each do |cmdname|
          lc = macho[cmdname].first

          # PPC and x86-family binaries don't have the same dylib LCs, so ignore
          # the ones that don't exist
          # https://github.com/Homebrew/ruby-macho/pull/24#issuecomment-226287121
          if lc
            assert_kind_of MachO::DylibCommand, lc

            dylib_name = lc.name

            assert dylib_name
            assert_kind_of MachO::LoadCommand::LCStr, dylib_name
          end
        end
      end
    end

    # TODO: figure out why we can't make dylibs with LC_LAZY_LOAD_DYLIB commands
    # @see https://github.com/Homebrew/ruby-macho/issues/6
  end

  def test_bundle
    filenames = FAT_ARCH_PAIRS.map { |a| fixture(a, "hellobundle.so") }

    filenames.each do |fn|
      file = MachO::FatFile.new(fn)

      assert file.bundle?
      filechecks(except = :bundle?).each do |check|
        refute file.send(check)
      end

      assert_equal "MH_BUNDLE", file.filetype
    end
  end

  def test_extract_macho
    groups = FAT_ARCH_PAIRS.map do |arch|
      ["hello.bin", "extracted_macho1", "extracted_macho2"].map do |fn|
        fixture(arch, fn)
      end
    end

    groups.each do |filename, extract1, extract2|
      file = MachO::FatFile.new(filename)

      assert file.machos.size == 2

      macho1 = file.extract(file.machos[0].cputype)
      macho2 = file.extract(file.machos[1].cputype)
      not_real = file.extract(:nonexistent)

      assert macho1
      assert macho2
      assert_nil not_real

      assert_equal file.machos[0].serialize, macho1.serialize
      assert_equal file.machos[1].serialize, macho2.serialize

      # write the extracted mach-os to disk
      macho1.write(extract1)
      macho2.write(extract2)

      # load them back to ensure they're intact/uncorrupted
      mfile1 = MachO::MachOFile.new(extract1)
      mfile2 = MachO::MachOFile.new(extract2)

      assert_equal file.machos[0].serialize, mfile1.serialize
      assert_equal file.machos[1].serialize, mfile2.serialize
    end
  ensure
    groups.each do |_, extract1, extract2|
      delete_if_exists(extract1)
      delete_if_exists(extract2)
    end
  end

  def test_change_dylib_id
    groups = FAT_ARCH_PAIRS.map do |arch|
      ["libhello.dylib", "libhello_actual.dylib", "libhello_expected.dylib"].map do |fn|
        fixture(arch, fn)
      end
    end

    groups.each do |filename, actual, expected|
      file = MachO::FatFile.new(filename)

      # changing the dylib id should work
      old_id = file.dylib_id
      file.dylib_id = "testing"
      assert_equal "testing", file.dylib_id

      # change it back within the same instance
      file.dylib_id = old_id
      assert_equal old_id, file.dylib_id

      really_big_id = "x" * 4096

      # test failsafe for excessively large IDs (w/ no special linking)
      assert_raises MachO::HeaderPadError do
        file.dylib_id = really_big_id
      end

      file.dylib_id = "test"

      file.write(actual)

      assert equal_sha1_hashes(actual, expected)
    end
  ensure
    groups.each do |_, actual, _|
      delete_if_exists(actual)
    end
  end

  def test_change_install_name
    groups = FAT_ARCH_PAIRS.map do |arch|
      ["hello.bin", "hello_actual.bin", "hello_expected.bin"].map do |fn|
        fixture(arch, fn)
      end
    end

    groups.each do |filename, actual, expected|
      file = MachO::FatFile.new(filename)

      dylibs = file.linked_dylibs

      # there should be at least one dylib linked to the binary
      refute_empty dylibs

      file.change_install_name(dylibs[0], "test")
      new_dylibs = file.linked_dylibs

      # the new dylib name should reflect the changes we've made
      assert_equal "test", new_dylibs[0]
      refute_equal dylibs[0], new_dylibs[0]

      file.write(actual)

      # compare actual and expected file hashes, to ensure file correctness
      assert equal_sha1_hashes(actual, expected)
    end
  ensure
    groups.each do |_, actual, _|
      delete_if_exists(actual)
    end
  end
end
