require_relative "helpers"

class MachOLoadCommandSerializationTest < Minitest::Test
  include Helpers

  def test_can_serialize
    filename = fixture(:i386, "hello.bin")
    file = MachO::MachOFile.new(filename)
    lc = file[:LC_SEGMENT].first

    refute lc.serializable?

    assert_raises MachO::LoadCommandNotSerializableError do
      lc.serialize(MachO::LoadCommands::LoadCommand::SerializationContext.context_for(file))
    end
  end

  def test_serialize_segment
    skip
  end

  def test_serialize_symtab
    skip
  end

  def test_serialize_symseg
    skip
  end

  def test_serialize_thread
    skip
  end

  def test_serialize_unixthread
    skip
  end

  def test_serialize_loadfvmlib
    skip
  end

  def test_serialize_ident
    skip
  end

  def test_serialize_fvmfile
    skip
  end

  def test_serialize_prepage
    skip
  end

  def test_serialize_dysymtab
    skip
  end

  def test_serialize_load_dylib
    filenames = SINGLE_ARCHES.map { |a| fixture(a, "hello.bin") }

    filenames.each do |filename|
      file = MachO::MachOFile.new(filename)
      ctx = MachO::LoadCommands::LoadCommand::SerializationContext.context_for(file)
      lc = file[:LC_LOAD_DYLIB].first
      lc2 = MachO::LoadCommands::LoadCommand.create(:LC_LOAD_DYLIB, lc.name.to_s,
                                                    lc.timestamp, lc.current_version,
                                                    lc.compatibility_version)
      blob = lc.view.raw_data[lc.view.offset, lc.cmdsize]

      assert_equal blob, lc.serialize(ctx)
      assert_equal blob, lc2.serialize(ctx)
    end
  end

  def test_serialize_id_dylib
    filenames = SINGLE_ARCHES.map { |a| fixture(a, "libhello.dylib") }

    filenames.each do |filename|
      file = MachO::MachOFile.new(filename)
      ctx = MachO::LoadCommands::LoadCommand::SerializationContext.context_for(file)
      lc = file[:LC_ID_DYLIB].first
      lc2 = MachO::LoadCommands::LoadCommand.create(:LC_ID_DYLIB, lc.name.to_s,
                                                    lc.timestamp, lc.current_version,
                                                    lc.compatibility_version)
      blob = lc.view.raw_data[lc.view.offset, lc.cmdsize]

      assert_equal blob, lc.serialize(ctx)
      assert_equal blob, lc2.serialize(ctx)
    end
  end

  def test_serialize_load_dylinker
    filenames = SINGLE_ARCHES.map { |a| fixture(a, "hello.bin") }

    filenames.each do |filename|
      file = MachO::MachOFile.new(filename)
      ctx = MachO::LoadCommands::LoadCommand::SerializationContext.context_for(file)
      lc = file[:LC_LOAD_DYLINKER].first
      lc2 = MachO::LoadCommands::LoadCommand.create(:LC_LOAD_DYLINKER, lc.name.to_s)
      blob = lc.view.raw_data[lc.view.offset, lc.cmdsize]

      assert_equal blob, lc.serialize(ctx)
      assert_equal blob, lc2.serialize(ctx)
    end
  end

  def test_serialize_id_dylinker
    skip
  end

  def test_serialize_prebound_dylib
    skip
  end

  def test_serialize_routines
    skip
  end

  def test_serialize_sub_framework
    skip
  end

  def test_serialize_sub_umbrella
    skip
  end

  def test_serialize_sub_client
    skip
  end

  def test_serialize_sub_library
    skip
  end

  def test_serialize_twolevel_hints
    skip
  end

  def test_serialize_prebind_cksum
    skip
  end

  def test_serialize_load_weak_dylib
    skip
  end

  def test_serialize_segment_64
    skip
  end

  def test_serialize_routines_64
    skip
  end

  def test_serialize_uuid
    skip
  end

  def test_serialize_rpath
    filenames = SINGLE_ARCHES.map { |a| fixture(a, "hello.bin") }

    filenames.each do |filename|
      file = MachO::MachOFile.new(filename)
      ctx = MachO::LoadCommands::LoadCommand::SerializationContext.context_for(file)
      lc = file[:LC_RPATH].first
      lc2 = MachO::LoadCommands::LoadCommand.create(:LC_RPATH, lc.path.to_s)
      blob = lc.view.raw_data[lc.view.offset, lc.cmdsize]

      assert_equal blob, lc.serialize(ctx)
      assert_equal blob, lc2.serialize(ctx)
    end
  end

  def test_serialize_code_signature
    skip
  end

  def test_serialize_segment_split_info
    skip
  end

  def test_serialize_reexport_dylib
    skip
  end

  def test_serialize_lazy_load_dylib
    skip
  end

  def test_serialize_encryption_info
    skip
  end

  def test_serialize_dyld_info
    skip
  end

  def test_serialize_dyld_info_only
    skip
  end

  def test_serialize_load_upward_dylib
    skip
  end

  def test_serialize_version_min_macosx
    skip
  end

  def test_serialize_version_min_iphoneos
    skip
  end

  def test_serialize_function_starts
    skip
  end

  def test_serialize_dyld_environment
    skip
  end

  def test_serialize_main
    skip
  end

  def test_serialize_data_in_code
    skip
  end

  def test_serialize_source_version
    skip
  end

  def test_serialize_dylib_code_sign_drs
    skip
  end

  def test_serialize_encryption_info_64
    skip
  end

  def test_serialize_linker_option
    skip
  end

  def test_serialize_linker_optimization_hint
    skip
  end

  def test_serialize_version_min_tvos
    skip
  end

  def test_serialize_version_min_watchos
    skip
  end
end
