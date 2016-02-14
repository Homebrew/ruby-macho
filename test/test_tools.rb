require "minitest/autorun"
require "helpers"
require "macho"

class MachOToolsTest < Minitest::Test
  include Helpers

  def test_dylibs
    dylibs = MachO::Tools.dylibs(TEST_EXE)

    assert dylibs
    assert_kind_of Array, dylibs

    dylibs.each do |dylib|
      assert dylib
      assert_kind_of String, dylib
    end
  end

  def test_dylibs_fat
    dylibs = MachO::Tools.dylibs(TEST_FAT_EXE)

    assert dylibs
    assert_kind_of Array, dylibs

    dylibs.each do |dylib|
      assert dylib
      assert_kind_of String, dylib
    end
  end

  def test_change_dylib_id
    pass
  end

  def test_change_dylib_id_fat
    pass
  end

  def test_change_install_name
    pass
  end

  def test_change_install_name_fat
    pass
  end

  def test_change_rpath
    pass
  end

  def test_change_rpath_fat
    pass
  end

  def test_add_rpath
    pass
  end

  def test_add_rpath_fat
    pass
  end

  def test_delete_rpath
    pass
  end

  def test_delete_rpath_fat
    pass
  end
end
