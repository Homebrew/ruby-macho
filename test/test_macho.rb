# frozen_string_literal: true

require_relative "helpers"

class MachOFileTest < Minitest::Test
  include Helpers

  def test_nonexistent_file
    assert_raises ArgumentError do
      MachO::MachOFile.new("/this/is/a/file/that/cannot/possibly/exist")
    end
  end

  def test_empty_file
    tempfile_with_data("empty_file", "") do |empty_file|
      assert_raises MachO::TruncatedFileError do
        MachO::MachOFile.new(empty_file.path)
      end
    end
  end

  def test_truncated_file
    tempfile_with_data("truncated_file", "\xFE\xED\xFA\xCE\x00\x00") do |truncated_file|
      assert_raises MachO::TruncatedFileError do
        MachO::MachOFile.new(truncated_file.path)
      end
    end
  end

  def test_load_commands
    filenames = SINGLE_ARCHES.map { |a| fixture(a, "hello.bin") }

    filenames.each do |fn|
      file = MachO::MachOFile.new(fn)

      file.load_commands.each do |lc|
        assert lc
        assert_kind_of MachO::LoadCommands::LoadCommand, lc
        assert_kind_of Integer, lc.offset
        assert_kind_of Integer, lc.cmd
        assert_kind_of Integer, lc.cmdsize
        assert_kind_of String, lc.to_s
        assert_kind_of Symbol, lc.type
        assert_kind_of Symbol, lc.to_sym
      end
    end
  end

  def test_load_commands_well_ordered
    filenames = SINGLE_ARCHES.map { |a| fixture(a, "libhello.dylib") }

    filenames.each do |fn|
      file = MachO::MachOFile.new(fn)
      offsets = file.load_commands.map { |lc| lc.view.offset }
      assert_equal offsets.sort, offsets
    end
  end

  def test_unknown_load_command
    filename = fixture(:x86_64, "hello_unk_lc.bin")

    # Unknown load command in non-permissive mode: raise exception.
    assert_raises MachO::LoadCommandError do
      MachO::MachOFile.new(filename)
    end

    # Unknown load command in permissive mode: treat as a generic LoadCommand.
    MachO::MachOFile.new(filename, :permissive => true)
  end

  def test_mach_header
    filenames = SINGLE_ARCHES.map { |a| fixture(a, "libhello.dylib") }

    filenames.each do |fn|
      file = MachO::MachOFile.new(fn)

      header = file.header

      assert header
      assert_kind_of MachO::Headers::MachHeader, header if file.magic32?
      assert_kind_of MachO::Headers::MachHeader64, header if file.magic64?
      assert_kind_of Integer, header.magic
      assert_kind_of Integer, header.cputype
      assert_kind_of Integer, header.cpusubtype
      assert_kind_of Integer, header.filetype
      assert_kind_of Integer, header.ncmds
      assert_kind_of Integer, header.sizeofcmds
      assert_kind_of Integer, header.flags
      refute header.flag?(:THIS_IS_A_MADE_UP_FLAG)
    end
  end

  def test_segments_and_sections
    filenames = SINGLE_ARCHES.map { |a| fixture(a, "hellobundle.so") }

    filenames.each do |fn|
      file = MachO::MachOFile.new(fn)

      assert_kind_of Integer, file.segment_alignment
      assert_operator file.segment_alignment, :<=, MachO::Sections::MAX_SECT_ALIGN

      segments = file.segments

      assert_kind_of Array, segments

      segments.each do |seg|
        assert seg

        assert_kind_of Integer, seg.guess_align
        assert_operator seg.guess_align, :<=, MachO::Sections::MAX_SECT_ALIGN

        assert_kind_of MachO::LoadCommands::SegmentCommand, seg if file.magic32?
        assert_kind_of MachO::LoadCommands::SegmentCommand64, seg if file.magic64?
        assert_kind_of String, seg.segname
        assert_equal seg.segname, seg.to_s
        assert_kind_of Integer, seg.vmaddr
        assert_kind_of Integer, seg.vmsize
        assert_kind_of Integer, seg.fileoff
        assert_kind_of Integer, seg.filesize
        assert_kind_of Integer, seg.maxprot
        assert_kind_of Integer, seg.initprot
        assert_kind_of Integer, seg.nsects
        assert_kind_of Integer, seg.flags
        refute seg.flag?(:THIS_IS_A_MADE_UP_FLAG)
        assert(MachO::LoadCommands::SEGMENT_FLAGS.keys.one? { |sf| seg.flag?(sf) }) if seg.flags != 0

        sections = seg.sections

        assert_kind_of Array, sections

        sections.each do |sect|
          assert sect

          assert_kind_of MachO::Sections::Section, sect if seg.is_a? MachO::LoadCommands::SegmentCommand
          assert_kind_of MachO::Sections::Section64, sect if seg.is_a? MachO::LoadCommands::SegmentCommand64
          assert_kind_of String, sect.sectname
          assert_kind_of String, sect.segname
          assert_kind_of Integer, sect.addr
          assert_kind_of Integer, sect.size
          assert_kind_of Integer, sect.offset
          assert_kind_of Integer, sect.align
          assert_kind_of Integer, sect.reloff
          assert_kind_of Integer, sect.nreloc
          assert_kind_of Integer, sect.flags
          refute sect.flag?(:THIS_IS_A_MADE_UP_FLAG)
          assert_kind_of Integer, sect.type
          assert MachO::Sections::SECTION_TYPES.values.include?(sect.type)
          assert(MachO::Sections::SECTION_TYPES.keys.one? { |st| sect.type?(st) })
          assert_kind_of Integer, sect.attributes
          assert(MachO::Sections::SECTION_ATTRIBUTES.keys.any? { |sa| sect.attribute?(sa) })
          assert_kind_of Integer, sect.reserved1
          assert_kind_of Integer, sect.reserved2
          assert_kind_of Integer, sect.reserved3 if sect.is_a? MachO::Sections::Section64
        end
      end
    end
  end

  def test_file
    filenames = SINGLE_ARCHES.map { |a| fixture(a, "hello.bin") }

    filenames.each do |fn|
      file = MachO::MachOFile.new(fn)

      assert file.serialize
      assert_kind_of String, file.serialize

      assert_kind_of Integer, file.magic
      assert_kind_of String, file.magic_string
      assert_kind_of Symbol, file.filetype
      assert_kind_of Symbol, file.cputype
      assert_kind_of Symbol, file.cpusubtype
      assert_kind_of Integer, file.ncmds
      assert_kind_of Integer, file.sizeofcmds
      assert_kind_of Integer, file.flags

      refute_predicate file.segments, :empty?
      refute_predicate file.linked_dylibs, :empty?
    end
  end

  def test_object
    filenames = SINGLE_ARCHES.map { |a| fixture(a, "hello.o") }

    filenames.each do |fn|
      file = MachO::MachOFile.new(fn)

      assert file.object?
      filechecks(:object?).each do |check|
        refute file.send(check)
      end

      assert_equal :object, file.filetype

      # it's not a dylib, so it has no dylib id
      assert_nil file.dylib_id
    end
  end

  def test_executable
    filenames = SINGLE_ARCHES.map { |a| fixture(a, "hello.bin") }

    filenames.each do |fn|
      file = MachO::MachOFile.new(fn)

      assert file.executable?
      filechecks(:executable?).each do |check|
        refute file.send(check)
      end

      assert_equal :execute, file.filetype

      # it's not a dylib, so it has no dylib id
      assert_nil file.dylib_id
    end
  end

  def test_dylib
    filenames = SINGLE_ARCHES.map { |a| fixture(a, "libhello.dylib") }

    filenames.each do |fn|
      file = MachO::MachOFile.new(fn)

      assert file.dylib?
      filechecks(:dylib?).each do |check|
        refute file.send(check)
      end

      assert_equal :dylib, file.filetype

      # it's a dylib, so it *must* have a dylib id
      assert file.dylib_id
    end
  end

  def test_extra_dylib
    filenames = SINGLE_ARCHES.map { |a| fixture(a, "libextrahello.dylib") }
    unusual_dylib_lcs = {
      LC_LOAD_UPWARD_DYLIB: :DYLIB_USE_UPWARD,
      LC_LAZY_LOAD_DYLIB: nil,
      LC_LOAD_WEAK_DYLIB: :DYLIB_USE_WEAK_LINK,
      LC_REEXPORT_DYLIB: :DYLIB_USE_REEXPORT,
    }

    filenames.each do |fn|
      file = MachO::MachOFile.new(fn)

      assert file.dylib?

      # make sure we can read more unusual dylib load commands
      unusual_dylib_lcs.each do |cmdname, flag_name|
        lc = file[cmdname].first

        # PPC and x86-family binaries don't have the same dylib LCs, so ignore
        # the ones that don't exist
        # https://github.com/Homebrew/ruby-macho/pull/24#issuecomment-226287121
        next unless lc

        assert_kind_of MachO::LoadCommands::DylibCommand, lc

        dylib_name = lc.name

        assert dylib_name
        assert_kind_of MachO::LoadCommands::LoadCommand::LCStr, dylib_name

        assert lc.flag?(flag_name) if flag_name
        (unusual_dylib_lcs.values - [flag_name]).compact.each do |other_flag_name|
          refute lc.flag?(other_flag_name)
        end
      end
    end
  end

  def test_dylib_use_command
    filenames = SINGLE_64_ARCHES.map { |a| fixture(a, "dylib_use_command-weak-delay.bin") }

    filenames.each do |fn|
      file = MachO::MachOFile.new(fn)

      lc = file[:LC_LOAD_WEAK_DYLIB].first
      lc2 = file[:LC_LOAD_DYLIB].first

      assert_instance_of MachO::LoadCommands::DylibUseCommand, lc
      assert_instance_of MachO::LoadCommands::DylibCommand, lc2

      refute_equal lc.flags, 0

      assert lc.flag?(:DYLIB_USE_WEAK_LINK)
      assert lc.flag?(:DYLIB_USE_DELAYED_INIT)
      refute lc.flag?(:DYLIB_USE_UPWARD)

      refute lc2.flag?(:DYLIB_USE_WEAK_LINK)
    end
  end

  def test_bundle
    filenames = SINGLE_ARCHES.map { |a| fixture(a, "hellobundle.so") }

    filenames.each do |fn|
      file = MachO::MachOFile.new(fn)

      # a file can only be ONE of these
      assert file.bundle?
      filechecks(:bundle?).each do |check|
        refute file.send(check)
      end

      assert_equal :bundle, file.filetype

      # it's not a dylib, so it has no dylib id
      assert_nil file.dylib_id
    end
  end

  def test_change_dylib_id
    groups = SINGLE_ARCHES.map do |arch|
      ["libhello.dylib", "libhello_actual.dylib", "libhello_expected.dylib"].map do |fn|
        fixture(arch, fn)
      end
    end

    groups.each do |filename, actual, expected|
      file = MachO::MachOFile.new(filename)

      # changing the dylib id should work
      old_id = file.dylib_id
      file.dylib_id = "testing"
      assert_equal "testing", file.dylib_id

      # change it back within the same instance
      file.dylib_id = old_id
      assert_equal old_id, file.dylib_id

      refute_predicate file.segments, :empty?
      refute_predicate file.linked_dylibs, :empty?

      really_big_id = "x" * 4096

      # test failsafe for excessively large IDs (w/ no special linking)
      assert_raises MachO::HeaderPadError do
        file.dylib_id = really_big_id
      end

      file.dylib_id = "test"

      file.write(actual)

      assert equal_sha1_hashes(actual, expected)

      act = MachO::MachOFile.new(actual)
      exp = MachO::MachOFile.new(expected)

      assert_equal file.ncmds, act.ncmds
      assert_equal exp.ncmds, act.ncmds

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
      file = MachO::MachOFile.new(filename)

      dylibs = file.linked_dylibs

      # there should be at least one dylib linked to the binary
      refute_empty dylibs

      file.change_install_name(dylibs[0], "test")
      new_dylibs = file.linked_dylibs

      # the new dylib name should reflect the changes we've made
      assert_equal "test", new_dylibs[0]
      refute_equal dylibs[0], new_dylibs[0]

      file.write(actual)

      assert equal_sha1_hashes(actual, expected)

      act = MachO::MachOFile.new(actual)
      exp = MachO::MachOFile.new(expected)

      assert_equal file.linked_dylibs.size, act.linked_dylibs.size
      assert_equal file.ncmds, act.ncmds
      assert_equal exp.linked_dylibs.size, act.linked_dylibs.size
      assert_equal exp.ncmds, act.ncmds

      assert_equal exp.linked_dylibs.first, act.linked_dylibs.first
    end
  ensure
    groups.each do |_, actual, _|
      delete_if_exists(actual)
    end
  end

  def test_change_install_name_preserves_type
    filename = fixture(:i386, "libextrahello.dylib")

    file = MachO::MachOFile.new(filename)
    old_dylib_types = file.dylib_load_commands.map(&:type)
    # this particular dylib is an LC_LOAD_UPWARD_DYLIB
    file.change_install_name("/usr/lib/libz.1.dylib", "test")
    new_dylib_types = file.dylib_load_commands.map(&:type)

    assert_equal old_dylib_types, new_dylib_types
  end

  def test_get_rpaths
    filenames = SINGLE_ARCHES.map { |a| fixture(a, "hello.bin") }

    filenames.each do |filename|
      file = MachO::MachOFile.new(filename)
      rpaths = file.rpaths

      assert_kind_of Array, rpaths
      assert_kind_of String, rpaths.first
      assert_equal "made_up_path", rpaths.first
    end
  end

  def test_change_rpath
    groups = SINGLE_ARCHES.map do |arch|
      ["", "_rpath_actual", "_rpath_expected"].map do |suffix|
        fixture(arch, "hello#{suffix}.bin")
      end
    end

    groups.each do |filename, actual, expected|
      file = MachO::MachOFile.new(filename)

      rpaths = file.rpaths

      # there should be at least one rpath in each binary
      refute_empty rpaths

      # We should ignore errors when changing to an existing rpath
      # This is the same behaviour as `install_name_tool`
      file.change_rpath(rpaths.first, rpaths.first)
      new_rpaths = file.rpaths

      assert_equal new_rpaths.first, rpaths.first
      refute_empty new_rpaths.first, rpaths.first

      file.change_rpath(rpaths.first, "/usr/lib")
      new_rpaths = file.rpaths

      # the new rpath should reflect the changes we've made
      assert_equal "/usr/lib", new_rpaths.first
      refute_empty rpaths.first, new_rpaths.first

      file.write(actual)

      assert equal_sha1_hashes(actual, expected)

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

  def test_delete_rpath
    groups = SINGLE_ARCHES.map do |arch|
      ["hello.bin", "hello_actual.bin"].map do |fn|
        fixture(arch, fn)
      end
    end

    groups << ["libdupe.dylib", "libdupe_actual.dylib"].map do |fn|
      fixture(:x86_64, fn)
    end

    groups.each do |filename, actual|
      file = MachO::MachOFile.new(filename)

      refute_empty file.rpaths
      orig_ncmds = current_ncmds = file.ncmds
      orig_sizeofcmds = file.sizeofcmds
      orig_npaths = current_npaths = file.rpaths.size

      file.rpaths.each do |rpath|
        file.delete_rpath(rpath)
        current_npaths -= 1
        current_ncmds -= 1

        assert_equal file.ncmds, current_ncmds
        assert_equal file.rpaths.size, current_npaths
        assert_operator file.sizeofcmds, :<, orig_sizeofcmds
      end

      file.write(actual)
      # ensure we can actually re-load and parse the modified file
      modified = MachO::MachOFile.new(actual)

      assert_empty modified.rpaths
      assert_equal file.serialize.bytesize, modified.serialize.bytesize
      assert_operator modified.ncmds, :<, orig_ncmds
      assert_operator modified.sizeofcmds, :<, orig_sizeofcmds
      assert_equal file.rpaths.size, modified.rpaths.size
      assert_operator modified.rpaths.size, :<, orig_npaths
    end
  ensure
    groups.each do |_, actual|
      delete_if_exists(actual)
    end
  end

  def test_delete_rpath_uniq
    groups = SINGLE_ARCHES.map do |arch|
      ["hello.bin", "hello_actual.bin"].map do |fn|
        fixture(arch, fn)
      end
    end

    groups << ["libdupe.dylib", "libdupe_actual.dylib"].map do |fn|
      fixture(:x86_64, fn)
    end

    groups.each do |filename, actual|
      file = MachO::MachOFile.new(filename)

      refute_empty file.rpaths
      orig_ncmds = file.ncmds
      orig_sizeofcmds = file.sizeofcmds
      orig_npaths = file.rpaths.size

      file.delete_rpath(file.rpaths.first, :uniq => true)
      assert_operator file.ncmds, :<, orig_ncmds
      assert_operator file.sizeofcmds, :<, orig_sizeofcmds
      assert_operator file.rpaths.size, :<, orig_npaths
      # libdupe rpaths: ["foo", "bar", "foo"]
      assert_equal file.rpaths, ["bar"] if filename.end_with?("libdupe.dylib")

      file.write(actual)
      # ensure we can actually re-load and parse the modified file
      modified = MachO::MachOFile.new(actual)

      assert_empty modified.rpaths unless filename.end_with?("libdupe.dylib")
      assert_equal file.serialize.bytesize, modified.serialize.bytesize
      assert_operator modified.ncmds, :<, orig_ncmds
      assert_operator modified.sizeofcmds, :<, orig_sizeofcmds
      assert_equal file.rpaths.size, modified.rpaths.size
      assert_operator modified.rpaths.size, :<, orig_npaths
    end
  ensure
    groups.each do |_, actual|
      delete_if_exists(actual)
    end
  end

  def test_delete_rpath_last
    groups = SINGLE_ARCHES.map do |arch|
      ["hello.bin", "hello_actual.bin"].map do |fn|
        fixture(arch, fn)
      end
    end

    groups << ["libdupe.dylib", "libdupe_actual.dylib"].map do |fn|
      fixture(:x86_64, fn)
    end

    groups.each do |filename, actual|
      file = MachO::MachOFile.new(filename)

      refute_empty file.rpaths
      orig_ncmds = file.ncmds
      orig_sizeofcmds = file.sizeofcmds
      orig_npaths = file.rpaths.size

      file.delete_rpath(file.rpaths.first, :last => true)
      assert_operator file.ncmds, :<, orig_ncmds
      assert_operator file.sizeofcmds, :<, orig_sizeofcmds
      assert_operator file.rpaths.size, :<, orig_npaths
      # libdupe rpaths: ["foo", "bar", "foo"]
      assert_equal file.rpaths, ["foo", "bar"] if filename.end_with?("libdupe.dylib")

      file.write(actual)
      # ensure we can actually re-load and parse the modified file
      modified = MachO::MachOFile.new(actual)

      assert_empty modified.rpaths unless filename.end_with?("libdupe.dylib")
      assert_equal file.serialize.bytesize, modified.serialize.bytesize
      assert_operator modified.ncmds, :<, orig_ncmds
      assert_operator modified.sizeofcmds, :<, orig_sizeofcmds
      assert_equal file.rpaths.size, modified.rpaths.size
      assert_operator modified.rpaths.size, :<, orig_npaths
    end
  ensure
    groups.each do |_, actual|
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
      file = MachO::MachOFile.new(filename)

      orig_ncmds = file.ncmds
      orig_sizeofcmds = file.sizeofcmds
      orig_npaths = file.rpaths.size

      file.add_rpath("/foo/bar/baz")
      assert_operator file.ncmds, :>, orig_ncmds
      assert_operator file.sizeofcmds, :>, orig_sizeofcmds
      assert_operator file.rpaths.size, :>, orig_npaths
      assert_includes file.rpaths, "/foo/bar/baz"

      file.write(actual)
      # ensure we can actually re-load and parse the modified file
      modified = MachO::MachOFile.new(actual)

      assert_equal file.serialize.bytesize, modified.serialize.bytesize
      assert_operator modified.ncmds, :>, orig_ncmds
      assert_operator modified.sizeofcmds, :>, orig_sizeofcmds
      assert_equal file.rpaths.size, modified.rpaths.size
      assert_operator modified.rpaths.size, :>, orig_npaths
      assert_includes modified.rpaths, "/foo/bar/baz"
    end
  ensure
    groups.each do |_, actual|
      delete_if_exists(actual)
    end
  end

  def test_rpath_exceptions
    filename = fixture(:i386, "hello.bin")
    file = MachO::MachOFile.new(filename)

    assert_raises MachO::RpathUnknownError do
      file.change_rpath("/this/rpath/doesn't/exist", "/lib")
    end

    assert_raises MachO::RpathExistsError do
      file.add_rpath(file.rpaths.first)
    end

    assert_raises MachO::RpathUnknownError do
      file.delete_rpath("/this/rpath/doesn't/exist")
    end
  end

  def test_fail_loading_fat
    filename = fixture(%w[i386 x86_64], "libhello.dylib")

    ex = assert_raises(MachO::FatBinaryError) do
      MachO::MachOFile.new_from_bin File.read(filename)
    end

    assert_match(/must be/, ex.inspect)
  end

  def test_to_h
    filename = fixture(:i386, "hello.bin")
    file = MachO::MachOFile.new(filename)
    hsh = file.to_h

    header_fields = %w[
      magic
      cputype
      cpusubtype
      filetype
      ncmds
      sizeofcmds
      flags
      alignment
    ]

    # fields in the header should be the same as in the hash representation
    header_fields.each do |field|
      assert_equal file.header.send(field), hsh["header"][field]
    end

    # additionally, symbol keys in the hash representation should correspond
    # to looked-up values in the header
    assert_equal MachO::Headers::MH_MAGICS[file.header.magic], hsh["header"]["magic_sym"]
    assert_equal MachO::Headers::CPU_TYPES[file.header.cputype], hsh["header"]["cputype_sym"]
    assert_equal MachO::Headers::CPU_SUBTYPES[file.header.cputype][file.header.cpusubtype], hsh["header"]["cpusubtype_sym"]
    assert_equal MachO::Headers::MH_FILETYPES[file.header.filetype], hsh["header"]["filetype_sym"]

    # the number of load commands should be the same in the hash representation
    assert_equal file.load_commands.size, hsh["load_commands"].size

    hsh["load_commands"].each do |lc_hsh|
      # each load command should have, at minimum, a cmd, cmdsize, type, view, and structure
      assert_kind_of Integer, lc_hsh["cmd"]
      assert_kind_of Integer, lc_hsh["cmdsize"]
      assert_kind_of Symbol, lc_hsh["type"]
      assert_kind_of Hash, lc_hsh["view"]
      assert_kind_of Hash, lc_hsh["structure"]

      # when looked up, cmd should correspond to type
      assert_equal lc_hsh["type"], MachO::LoadCommands::LOAD_COMMANDS[lc_hsh["cmd"]]

      # the view should contain an endianness and an offset
      assert_kind_of Symbol, lc_hsh["view"]["endianness"]
      assert_kind_of Integer, lc_hsh["view"]["offset"]

      # the structure should contain a format and a bytesize
      assert_kind_of String, lc_hsh["structure"]["format"]
      assert_kind_of Integer, lc_hsh["structure"]["bytesize"]
    end
  end
end
