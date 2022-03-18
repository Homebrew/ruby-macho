# frozen_string_literal: true

require_relative "helpers"

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

  def test_zero_arch_file
    assert_raises MachO::ZeroArchitectureError do
      MachO::FatFile.new("test/bin/llvm/macho-invalid-fat-header")
    end

    MachO::FatFile.new("test/bin/llvm/macho-invalid-fat-header", :permissive => true)
  end

  def test_fat_header
    filenames = FAT_ARCH_PAIRS.map { |a| fixture(a, "hello.bin") }

    filenames.each do |fn|
      file = MachO::FatFile.new(fn)

      header = file.header

      assert header
      assert_kind_of MachO::Headers::FatHeader, header
      assert_kind_of Integer, header.magic
      assert_kind_of Integer, header.nfat_arch
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
        assert_kind_of MachO::Headers::FatArch, arch
        assert_kind_of Integer, arch.cputype
        assert_kind_of Integer, arch.cpusubtype
        assert_kind_of Integer, arch.offset
        assert_kind_of Integer, arch.size
        assert_kind_of Integer, arch.align
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

      assert_kind_of Integer, file.magic
      assert_kind_of String, file.magic_string
      assert_kind_of Symbol, file.filetype
    end
  end

  def test_object
    filenames = FAT_ARCH_PAIRS.map { |a| fixture(a, "hello.o") }

    filenames.each do |fn|
      file = MachO::FatFile.new(fn)

      assert file.object?
      filechecks(:object?).each do |check|
        refute file.send(check)
      end

      assert_equal :object, file.filetype
    end
  end

  def test_executable
    filenames = FAT_ARCH_PAIRS.map { |a| fixture(a, "hello.bin") }

    filenames.each do |fn|
      file = MachO::FatFile.new(fn)

      assert file.executable?
      filechecks(:executable?).each do |check|
        refute file.send(check)
      end

      assert_equal :execute, file.filetype
    end
  end

  def test_dylib
    filenames = FAT_ARCH_PAIRS.map { |a| fixture(a, "libhello.dylib") }

    filenames.each do |fn|
      file = MachO::FatFile.new(fn)

      assert file.dylib?
      filechecks(:dylib?).each do |check|
        refute file.send(check)
      end

      assert_equal :dylib, file.filetype
    end
  end

  def test_extra_dylib
    filenames = FAT_ARCH_PAIRS.map { |a| fixture(a, "libextrahello.dylib") }
    unusual_dylib_lcs = %i[
      LC_LOAD_UPWARD_DYLIB
      LC_LAZY_LOAD_DYLIB
      LC_LOAD_WEAK_DYLIB
      LC_REEXPORT_DYLIB
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
          next unless lc

          assert_kind_of MachO::LoadCommands::DylibCommand, lc

          dylib_name = lc.name

          assert dylib_name
          assert_kind_of MachO::LoadCommands::LoadCommand::LCStr, dylib_name
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
      filechecks(:bundle?).each do |check|
        refute file.send(check)
      end

      assert_equal :bundle, file.filetype
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

  def test_new_from_machos
    filenames = SINGLE_ARCHES.map { |a| fixture(a, "hello.bin") }
    machos = filenames.map { |f| MachO::MachOFile.new(f) }

    file = MachO::FatFile.new_from_machos(*machos)

    assert file
    assert_instance_of MachO::FatFile, file

    # the number of machos inside the new fat file should be the number
    # of individual machos we gave it
    assert machos.size, file.machos.size

    # the order of machos within the fat file should be preserved
    machos.each_with_index do |macho, i|
      assert_equal macho.cputype, file.machos[i].cputype
    end

    # we should be able to dump the newly created fat file
    file.write("merged_machos.bin")

    # ...and load it back as a new object without errors
    file = MachO::FatFile.new("merged_machos.bin")

    assert file
  ensure
    delete_if_exists("merged_machos.bin")
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

      file.change_install_name(dylibs.first, "test")
      new_dylibs = file.linked_dylibs

      # the new dylib name should reflect the changes we've made
      assert_equal "test", new_dylibs.first
      refute_equal dylibs.first, new_dylibs.first

      file.write(actual)

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

  def test_get_rpaths
    groups = FAT_ARCH_PAIRS.map do |arch|
      ["", "_actual", "_expected"].map do |fn|
        fixture(arch, "hello#{fn}.bin")
      end
    end

    groups.each do |filename, _, _|
      file = MachO::FatFile.new(filename)
      rpaths = file.rpaths

      assert_kind_of Array, rpaths
      assert_kind_of String, rpaths.first
      assert_equal "made_up_path", rpaths.first
    end
  end

  def test_change_rpath
    groups = FAT_ARCH_PAIRS.map do |arch|
      ["", "_rpath_actual", "_rpath_expected"].map do |fn|
        fixture(arch, "hello#{fn}.bin")
      end
    end

    groups.each do |filename, actual, expected|
      file = MachO::FatFile.new(filename)
      rpaths = file.rpaths

      # there should be at least one rpath in each binary
      refute_empty rpaths

      file.change_rpath(rpaths.first, "/usr/lib")
      new_rpaths = file.rpaths

      # the new rpath should reflect the changes we've made
      assert_equal "/usr/lib", new_rpaths.first
      refute_empty rpaths.first, new_rpaths.first

      file.write(actual)

      assert equal_sha1_hashes(actual, expected)

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

  def test_delete_rpath
    groups = FAT_ARCH_PAIRS.map do |arch|
      ["hello.bin", "hello_actual.bin"].map do |fn|
        fixture(arch, fn)
      end
    end

    groups.each do |filename, actual|
      file = MachO::FatFile.new(filename)

      refute_empty file.rpaths
      orig_npaths = file.rpaths.size

      file.delete_rpath(file.rpaths.first)
      assert_operator file.rpaths.size, :<, orig_npaths

      file.write(actual)
      # ensure we can actually re-load and parse the modified file
      modified = MachO::FatFile.new(actual)

      assert_equal file.serialize.size, modified.serialize.size
      assert_equal file.rpaths.size, modified.rpaths.size
      assert_operator modified.rpaths.size, :<, orig_npaths
    end
  ensure
    groups.each do |_, actual|
      delete_if_exists(actual)
    end
  end

  def test_add_rpath
    groups = FAT_ARCH_PAIRS.map do |arch|
      ["hello.bin", "hello_actual.bin"].map do |fn|
        fixture(arch, fn)
      end
    end

    groups.each do |filename, actual|
      file = MachO::FatFile.new(filename)

      orig_npaths = file.rpaths.size

      file.add_rpath("/foo/bar/baz")
      assert_operator file.rpaths.size, :>, orig_npaths
      assert_includes file.rpaths, "/foo/bar/baz"

      file.write(actual)
      # ensure we can actually re-load and parse the modified file
      modified = MachO::FatFile.new(actual)

      assert_equal file.serialize.size, modified.serialize.size
      assert_equal file.rpaths.size, modified.rpaths.size
      assert_operator modified.rpaths.size, :>, orig_npaths
      assert_includes modified.rpaths, "/foo/bar/baz"
    end
  ensure
    groups.each do |_, actual|
      delete_if_exists(actual)
    end
  end

  def test_inconsistent_slices
    filename = fixture(%i[i386 x86_64], "libinconsistent.dylib")

    file = MachO::FatFile.new(filename)

    # the individual slices should have different sets of dylibs
    refute_equal file.machos[0].linked_dylibs, file.machos[1].linked_dylibs

    # modifications are strict by default
    assert_raises MachO::DylibUnknownError do
      # libz only exists in one of the slices
      file.change_install_name("/usr/lib/libz.1.dylib", "foo")
    end

    # completely incorrect modifications still fail with nonstrict
    assert_raises MachO::DylibUnknownError do
      # foo exists in none of the slices
      file.change_install_name("foo", "bar", :strict => false)
    end

    # with nonstrict, valid modifications should succeed for the right slice(s)
    file.change_install_name("/usr/lib/libz.1.dylib", "foo", :strict => false)

    # ...but not all slices will have the modified dylib
    refute(file.machos.all? { |m| m.linked_dylibs.include?("foo") })

    # ...but at least one will
    assert(file.machos.any? { |m| m.linked_dylibs.include?("foo") })
  end

  def test_dylib_load_commands
    filenames = FAT_ARCH_PAIRS.map { |a| fixture(a, "hello.bin") }

    filenames.each do |filename|
      file = MachO::FatFile.new(filename)

      assert_instance_of Array, file.dylib_load_commands

      file.dylib_load_commands.each do |lc|
        assert_kind_of MachO::LoadCommands::DylibCommand, lc
      end
    end
  end

  def test_fail_loading_thin
    filename = fixture("x86_64", "libhello.dylib")

    ex = assert_raises(MachO::MachOBinaryError) do
      MachO::FatFile.new_from_bin File.read(filename)
    end

    assert_match(/must be/, ex.inspect)
  end

  def test_to_h
    filename = fixture(%i[i386 x86_64], "hello.bin")
    file = MachO::FatFile.new(filename)
    hsh = file.to_h

    # the hash representation of a FatFile should have at least a header, fat_archs, and machos
    assert_kind_of Hash, hsh["header"]
    assert_kind_of Array, hsh["fat_archs"]
    assert_kind_of Array, hsh["machos"]

    header_fields = %w[
      magic
      nfat_arch
    ]

    # fields in the header should be the same as in the hash representation
    header_fields.each do |field|
      assert_equal file.header.send(field), hsh["header"][field]
    end

    # additionally, symbol keys in the hash representation should correspond
    # to looked-up values in the header
    assert_equal MachO::Headers::MH_MAGICS[file.header.magic], hsh["header"]["magic_sym"]

    fat_arch_fields = %w[
      cputype
      cpusubtype
      offset
      size
      align
    ]

    # fields in each FatArch should be the same as in the hash representation
    #
    # additionally, symbol keys in the hash representation of each FatArch should
    # correspond to looked up values
    file.fat_archs.zip(hsh["fat_archs"]).each do |fa, fa_hsh|
      fat_arch_fields.each do |field|
        assert_equal fa.send(field), fa_hsh[field]
      end

      assert_equal MachO::Headers::CPU_TYPES[fa.cputype], fa_hsh["cputype_sym"]
      assert_equal MachO::Headers::CPU_SUBTYPES[fa.cputype][fa.cpusubtype], fa_hsh["cpusubtype_sym"]
    end
  end
end
