require_relative "helpers"

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

      act = MachO::MachOFile.new(actual)
      exp = MachO::MachOFile.new(expected)

      assert_equal exp.dylib_id, act.dylib_id
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

      act = MachO::FatFile.new(actual)
      exp = MachO::FatFile.new(expected)

      assert_equal exp.dylib_id, act.dylib_id
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

      act = MachO::MachOFile.new(actual)
      exp = MachO::MachOFile.new(expected)

      assert_equal exp.linked_dylibs.first, act.linked_dylibs.first
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

      act = MachO::FatFile.new(actual)
      exp = MachO::FatFile.new(expected)

      assert_equal exp.linked_dylibs.first, act.linked_dylibs.first
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

      file = MachO::MachOFile.new(filename)
      act = MachO::MachOFile.new(actual)
      exp = MachO::MachOFile.new(expected)

      assert_equal file.rpaths.size, act.rpaths.size
      assert_equal file.ncmds, act.ncmds
      assert_equal exp.rpaths.size, act.rpaths.size
      assert_equal exp.ncmds, act.ncmds

      assert_equal exp.rpaths.first, act.rpaths.first
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

      file = MachO::FatFile.new(filename)
      act = MachO::FatFile.new(actual)
      exp = MachO::FatFile.new(expected)

      assert_equal file.rpaths.size, act.rpaths.size
      assert_equal exp.rpaths.size, act.rpaths.size

      assert_equal exp.rpaths.first, act.rpaths.first
    end
  ensure
    groups.each do |_, actual, _|
      delete_if_exists(actual)
    end
  end

  def test_add_rpath
    groups = SINGLE_ARCHES.map do |arch|
      ["hello.bin", "hello_actual.bin"].map do |fn|
        fixture(arch, fn)
      end
    end

    groups.each do |filename, actual|
      FileUtils.cp filename, actual
      MachO::Tools.add_rpath(actual, "/foo/bar/baz")

      original = MachO::MachOFile.new(filename)
      modified = MachO::MachOFile.new(actual)

      assert_operator modified.ncmds, :>, original.ncmds
      assert_operator modified.sizeofcmds, :>, original.sizeofcmds
      assert_operator modified.rpaths.size, :>, original.rpaths.size
      refute_includes original.rpaths, "/foo/bar/baz"
      assert_includes modified.rpaths, "/foo/bar/baz"
    end
  ensure
    groups.each do |_, actual|
      delete_if_exists(actual)
    end
  end

  def test_add_rpath_fat
    groups = FAT_ARCH_PAIRS.map do |arch|
      ["hello.bin", "hello_actual.bin"].map do |fn|
        fixture(arch, fn)
      end
    end

    groups.each do |filename, actual|
      FileUtils.cp filename, actual
      MachO::Tools.add_rpath(actual, "/foo/bar/baz")

      original = MachO::FatFile.new(filename)
      modified = MachO::FatFile.new(actual)

      refute_includes original.rpaths, "/foo/bar/baz"
      assert_includes modified.rpaths, "/foo/bar/baz"
    end
  ensure
    groups.each do |_, actual|
      delete_if_exists(actual)
    end
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

  def test_merge_machos
    filenames = SINGLE_ARCHES.map { |a| fixture(a, "hello.bin") }
    merged_filename = "merged_machos.bin"

    # merge a bunch of single-arch Mach-Os and save them as a universal
    MachO::Tools.merge_machos(merged_filename, *filenames)

    # ensure that we can load the merged machos
    file = MachO::FatFile.new(merged_filename)

    assert file
    assert_instance_of MachO::FatFile, file
    assert_equal filenames.size, file.machos.size
  ensure
    delete_if_exists(merged_filename)
  end

  def test_merge_machos_fat
    filenames = FAT_ARCH_PAIRS.map { |a| fixture(a, "hello.bin") }
    merged_filename = "merged_universals.bin"

    # merge a bunch of universal Mach-Os and save them as one universal
    MachO::Tools.merge_machos(merged_filename, *filenames)

    # ensure that we can load the merged machos
    file = MachO::FatFile.new(merged_filename)

    assert file
    assert_instance_of MachO::FatFile, file
  ensure
    delete_if_exists(merged_filename)
  end
end
