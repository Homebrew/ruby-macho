require "minitest/autorun"
require "helpers"
require "macho"

class MachOToolsTest < Minitest::Test
  include Helpers

  def test_dylibs
    dylibs = MachO::Tools.dylibs(fixture(:x86_64, "hello.bin"))

    assert dylibs
    assert_kind_of Array, dylibs

    dylibs.each do |dylib|
      assert dylib
      assert_kind_of String, dylib
    end
  end

  def test_dylibs_fat
    dylibs = MachO::Tools.dylibs(fixture([:i386, :x86_64], "hello.bin"))

    assert dylibs
    assert_kind_of Array, dylibs

    dylibs.each do |dylib|
      assert dylib
      assert_kind_of String, dylib
    end
  end

  def test_change_dylib_id
    groups = SINGLE_ARCHES.map do |arch|
      ["libhello.dylib", "libhello_actual.dylib", "libhello_expected.dylib"].map do |fn|
        fixture(arch, fn)
      end
    end

    groups.each do |filename, actual, expected|
      FileUtils.cp filename, actual
      MachO::Tools.change_dylib_id(actual, "test")

      assert equal_sha1_hashes(actual, expected)
    end
  ensure
    groups.each do |_, actual, _|
      delete_if_exists(actual)
    end
  end

  def test_change_dylib_id_fat
    groups = FAT_ARCH_PAIRS.map do |arch|
      ["libhello.dylib", "libhello_actual.dylib", "libhello_expected.dylib"].map do |fn|
        fixture(arch, fn)
      end
    end

    groups.each do |filename, actual, expected|
      FileUtils.cp filename, actual
      MachO::Tools.change_dylib_id(actual, "test")

      assert equal_sha1_hashes(actual, expected)
    end
  ensure
    groups.each do |_, actual, _|
      delete_if_exists(actual)
    end
  end

  def test_change_install_name
    groups = SINGLE_ARCHES.map do |arch|
      ["hello.bin", "hello_actual.bin", "hello_expected.bin"].map do |fn|
        fixture(arch, fn)
      end
    end

    groups.each do |filename, actual, expected|
      FileUtils.cp filename, actual
      oldname = MachO::Tools.dylibs(actual).first
      MachO::Tools.change_install_name(actual, oldname, "test")

      assert equal_sha1_hashes(actual, expected)
    end
  ensure
    groups.each do |_, actual, _|
      delete_if_exists(actual)
    end
  end

  def test_change_install_name_fat
    groups = FAT_ARCH_PAIRS.map do |arch|
      ["hello.bin", "hello_actual.bin", "hello_expected.bin"].map do |fn|
        fixture(arch, fn)
      end
    end

    groups.each do |filename, actual, expected|
      FileUtils.cp filename, actual
      oldname = MachO::Tools.dylibs(actual).first
      MachO::Tools.change_install_name(actual, oldname, "test")

      assert equal_sha1_hashes(actual, expected)
    end
  ensure
    groups.each do |_, actual, _|
      delete_if_exists(actual)
    end
  end

  def test_change_rpath
    groups = SINGLE_ARCHES.map do |arch|
      ["hello.bin", "hello_actual.bin", "hello_rpath_expected.bin"].map do |fn|
        fixture(arch, fn)
      end
    end

    groups.each do |filename, actual, expected|
      FileUtils.cp filename, actual
      MachO::Tools.change_rpath(actual, "made_up_path", "/usr/lib")

      assert equal_sha1_hashes(actual, expected)
    end
  ensure
    groups.each do |_, actual, _|
      delete_if_exists(actual)
    end
  end

  def test_change_rpath_fat
    groups = FAT_ARCH_PAIRS.map do |arch|
      ["hello.bin", "hello_actual.bin", "hello_rpath_expected.bin"].map do |fn|
        fixture(arch, fn)
      end
    end

    groups.each do |filename, actual, expected|
      FileUtils.cp filename, actual
      MachO::Tools.change_rpath(actual, "made_up_path", "/usr/lib")

      assert equal_sha1_hashes(actual, expected)
    end
  ensure
    groups.each do |_, actual, _|
      delete_if_exists(actual)
    end
  end

  def test_add_rpath
    pass
  end

  def test_add_rpath_fat
    pass
  end

  def test_delete_rpath
    groups = SINGLE_ARCHES.map do |arch|
      ["hello.bin", "hello_actual.bin"].map do |fn|
        fixture(arch, fn)
      end
    end

    groups.each do |filename, actual|
      FileUtils.cp filename, actual
      MachO::Tools.delete_rpath(actual, "made_up_path")

      original = MachO::MachOFile.new(filename)
      modified = MachO::MachOFile.new(actual)

      assert_operator modified.ncmds, :<, original.ncmds
      assert_operator modified.sizeofcmds, :<, original.sizeofcmds
      assert_operator modified.rpaths.size, :<, original.rpaths.size
      assert_includes original.rpaths, "made_up_path"
      refute_includes modified.rpaths, "made_up_path"
    end
  ensure
    groups.each do |_, actual|
      delete_if_exists(actual)
    end
  end

  def test_delete_rpath_fat
    groups = FAT_ARCH_PAIRS.map do |arch|
      ["hello.bin", "hello_actual.bin"].map do |fn|
        fixture(arch, fn)
      end
    end

    groups.each do |filename, actual|
      FileUtils.cp filename, actual
      MachO::Tools.delete_rpath(actual, "made_up_path")

      original = MachO::FatFile.new(filename)
      modified = MachO::FatFile.new(actual)

      assert_operator modified.rpaths.size, :<, original.rpaths.size
      assert_includes original.rpaths, "made_up_path"
      refute_includes modified.rpaths, "made_up_path"
    end
  ensure
    groups.each do |_, actual|
      delete_if_exists(actual)
    end
  end
end
