require "minitest/autorun"
require "helpers"
require "macho"

class MachOLoadCommandSerializationTest < Minitest::Test
  include Helpers

  def test_can_serialize
    filename = fixture(:i386, "hello.bin")
    file = MachO::MachOFile.new(filename)
    lc = file[:LC_SEGMENT].first

    refute lc.serializable?

    assert_raises MachO::LoadCommandNotSerializableError do
      lc.serialize(MachO::LoadCommand::SerializationContext.context_for(file))
    end
  end

  def test_serialize_segment
    pass
  end

  def test_serialize_symtab
    pass
  end

  def test_serialize_symseg
    pass
  end

  def test_serialize_thread
    pass
  end

  def test_serialize_unixthread
    pass
  end

  def test_serialize_loadfvmlib
    pass
  end

  def test_serialize_ident
    pass
  end

  def test_serialize_fvmfile
    pass
  end

  def test_serialize_prepage
    pass
  end

  def test_serialize_dysymtab
    pass
  end

  def test_serialize_load_dylib
    filenames = SINGLE_ARCHES.map { |a| fixture(a, "hello.bin") }

    filenames.each do |filename|
      file = MachO::MachOFile.new(filename)
      ctx = MachO::LoadCommand::SerializationContext.context_for(file)
      lc = file[:LC_LOAD_DYLIB].first
      lc2 = MachO::LoadCommand.create(:LC_LOAD_DYLIB, lc.name.to_s,
        lc.timestamp, lc.current_version, lc.compatibility_version)
      blob = lc.view.raw_data[lc.view.offset, lc.cmdsize]

      assert_equal blob, lc.serialize(ctx)
      assert_equal blob, lc2.serialize(ctx)
    end
  end

  def test_serialize_id_dylib
    filenames = SINGLE_ARCHES.map { |a| fixture(a, "libhello.dylib") }

    filenames.each do |filename|
      file = MachO::MachOFile.new(filename)
      ctx = MachO::LoadCommand::SerializationContext.context_for(file)
      lc = file[:LC_ID_DYLIB].first
      lc2 = MachO::LoadCommand.create(:LC_ID_DYLIB, lc.name.to_s,
        lc.timestamp, lc.current_version, lc.compatibility_version)
      blob = lc.view.raw_data[lc.view.offset, lc.cmdsize]

      assert_equal blob, lc.serialize(ctx)
      assert_equal blob, lc2.serialize(ctx)
    end
  end

  def test_serialize_load_dylinker
    filenames = SINGLE_ARCHES.map { |a| fixture(a, "hello.bin") }

    filenames.each do |filename|
      file = MachO::MachOFile.new(filename)
      ctx = MachO::LoadCommand::SerializationContext.context_for(file)
      lc = file[:LC_LOAD_DYLINKER].first
      lc2 = MachO::LoadCommand.create(:LC_LOAD_DYLINKER, lc.name.to_s)
      blob = lc.view.raw_data[lc.view.offset, lc.cmdsize]

      assert_equal blob, lc.serialize(ctx)
      assert_equal blob, lc2.serialize(ctx)
    end
  end

  def test_serialize_id_dylinker
    pass
  end

  def test_serialize_prebound_dylib
    pass
  end

  def test_serialize_routines
    pass
  end

  def test_serialize_sub_framework
    pass
  end

  def test_serialize_sub_umbrella
    pass
  end

  def test_serialize_sub_client
    pass
  end

  def test_serialize_sub_library
    pass
  end

  def test_serialize_twolevel_hints
    pass
  end

  def test_serialize_prebind_cksum
    pass
  end

  def test_serialize_load_weak_dylib
    pass
  end

  def test_serialize_segment_64
    pass
  end

  def test_serialize_routines_64
    pass
  end

  def test_serialize_uuid
    pass
  end

  def test_serialize_rpath
    filenames = SINGLE_ARCHES.map { |a| fixture(a, "hello.bin") }

    filenames.each do |filename|
      file = MachO::MachOFile.new(filename)
      ctx = MachO::LoadCommand::SerializationContext.context_for(file)
      lc = file[:LC_RPATH].first
      lc2 = MachO::LoadCommand.create(:LC_RPATH, lc.path.to_s)
      blob = lc.view.raw_data[lc.view.offset, lc.cmdsize]

      assert_equal blob, lc.serialize(ctx)
      assert_equal blob, lc2.serialize(ctx)
    end
  end

  def test_serialize_code_signature
    pass
  end

  def test_serialize_segment_split_info
    pass
  end

  def test_serialize_reexport_dylib
    pass
  end

  def test_serialize_lazy_load_dylib
    pass
  end

  def test_serialize_encryption_info
    pass
  end

  def test_serialize_dyld_info
    pass
  end

  def test_serialize_dyld_info_only
    pass
  end

  def test_serialize_load_upward_dylib
    pass
  end

  def test_serialize_version_min_macosx
    pass
  end

  def test_serialize_version_min_iphoneos
    pass
  end

  def test_serialize_function_starts
    pass
  end

  def test_serialize_dyld_environment
    pass
  end

  def test_serialize_main
    pass
  end

  def test_serialize_data_in_code
    pass
  end

  def test_serialize_source_version
    pass
  end

  def test_serialize_dylib_code_sign_drs
    pass
  end

  def test_serialize_encryption_info_64
    pass
  end

  def test_serialize_linker_option
    pass
  end

  def test_serialize_linker_optimization_hint
    pass
  end

  def test_serialize_version_min_tvos
    pass
  end

  def test_serialize_version_min_watchos
    pass
  end
end
