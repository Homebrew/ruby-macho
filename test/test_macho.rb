require "minitest/autorun"
require "helpers"
require "macho"

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
        assert_equal MachO::LoadCommand, lc.class.superclass
        assert_kind_of Fixnum, lc.offset
        assert_kind_of Fixnum, lc.cmd
        assert_kind_of Fixnum, lc.cmdsize
        assert_kind_of String, lc.to_s
        assert_kind_of Symbol, lc.type
        assert_kind_of Symbol, lc.to_sym
      end
    end
  end

  def test_mach_header
    filenames = SINGLE_ARCHES.map { |a| fixture(a, "libhello.dylib") }

    filenames.each do |fn|
      file = MachO::MachOFile.new(fn)

      header = file.header

      assert header
      assert_kind_of MachO::MachHeader, header if file.magic32?
      assert_kind_of MachO::MachHeader64, header if file.magic64?
      assert_kind_of Fixnum, header.magic
      assert_kind_of Fixnum, header.cputype
      assert_kind_of Fixnum, header.cpusubtype
      assert_kind_of Fixnum, header.filetype
      assert_kind_of Fixnum, header.ncmds
      assert_kind_of Fixnum, header.sizeofcmds
      assert_kind_of Fixnum, header.flags
      refute header.flag?(:THIS_IS_A_MADE_UP_FLAG)
    end
  end

  def test_segments_and_sections
    filenames = SINGLE_ARCHES.map { |a| fixture(a, "hellobundle.so") }

    filenames.each do |fn|
      file = MachO::MachOFile.new(fn)

      segments = file.segments

      assert_kind_of Array, segments

      segments.each do |seg|
        assert seg
        assert_kind_of MachO::SegmentCommand, seg if file.magic32?
        assert_kind_of MachO::SegmentCommand64, seg if file.magic64?
        assert_kind_of String, seg.segname
        assert_kind_of Fixnum, seg.vmaddr
        assert_kind_of Fixnum, seg.vmsize
        assert_kind_of Fixnum, seg.fileoff
        assert_kind_of Fixnum, seg.filesize
        assert_kind_of Fixnum, seg.maxprot
        assert_kind_of Fixnum, seg.initprot
        assert_kind_of Fixnum, seg.nsects
        assert_kind_of Fixnum, seg.flags
        refute seg.flag?(:THIS_IS_A_MADE_UP_FLAG)

        sections = file.sections(seg)

        assert_kind_of Array, sections

        sections.each do |sect|
          assert sect
          assert_kind_of MachO::Section, sect if seg.is_a? MachO::SegmentCommand
          assert_kind_of MachO::Section64, sect if seg.is_a? MachO::SegmentCommand64
          assert_kind_of String, sect.sectname
          assert_kind_of String, sect.segname
          assert_kind_of Fixnum, sect.addr
          assert_kind_of Fixnum, sect.size
          assert_kind_of Fixnum, sect.offset
          assert_kind_of Fixnum, sect.align
          assert_kind_of Fixnum, sect.reloff
          assert_kind_of Fixnum, sect.nreloc
          assert_kind_of Fixnum, sect.flags
          refute sect.flag?(:THIS_IS_A_MADE_UP_FLAG)
          assert_kind_of Fixnum, sect.reserved1
          assert_kind_of Fixnum, sect.reserved2
          assert_kind_of Fixnum, sect.reserved3 if sect.is_a? MachO::Section64
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

      assert_kind_of Fixnum, file.magic
      assert_kind_of String, file.magic_string
      assert_kind_of String, file.filetype
      assert_kind_of Symbol, file.cputype
      assert_kind_of Symbol, file.cpusubtype
      assert_kind_of Fixnum, file.ncmds
      assert_kind_of Fixnum, file.sizeofcmds
      assert_kind_of Fixnum, file.flags

      assert file.segments.size > 0
      assert file.linked_dylibs.size > 0
    end
  end

  def test_object
    filenames = SINGLE_ARCHES.map { |a| fixture(a, "hello.o") }

    filenames.each do |fn|
      file = MachO::MachOFile.new(fn)

      assert file.object?
      filechecks(except = :object?).each do |check|
        refute file.send(check)
      end

      assert_equal "MH_OBJECT", file.filetype

      # it's not a dylib, so it has no dylib id
      assert_nil file.dylib_id
    end
  end

  def test_executable
    filenames = SINGLE_ARCHES.map { |a| fixture(a, "hello.bin") }

    filenames.each do |fn|
      file = MachO::MachOFile.new(fn)

      assert file.executable?
      filechecks(except = :executable?).each do |check|
        refute file.send(check)
      end

      assert_equal "MH_EXECUTE", file.filetype

      # it's not a dylib, so it has no dylib id
      assert_nil file.dylib_id
    end
  end

  def test_dylib
    filenames = SINGLE_ARCHES.map { |a| fixture(a, "libhello.dylib") }

    filenames.each do |fn|
      file = MachO::MachOFile.new(fn)

      assert file.dylib?
      filechecks(except = :dylib?).each do |check|
        refute file.send(check)
      end

      assert_equal "MH_DYLIB", file.filetype

      # it's a dylib, so it *must* have a dylib id
      assert file.dylib_id
    end
  end

  def test_extra_dylib
    filenames = SINGLE_ARCHES.map { |a| fixture(a, "libextrahello.dylib") }
    unusual_dylib_lcs = [
      :LC_LOAD_UPWARD_DYLIB,
      :LC_LAZY_LOAD_DYLIB,
      :LC_LOAD_WEAK_DYLIB,
      :LC_REEXPORT_DYLIB
    ]

    filenames.each do |fn|
      file = MachO::MachOFile.new(fn)

      assert file.dylib?

      # make sure we can read more unusual dylib load commands
      unusual_dylib_lcs.each do |cmdname|
        lc = file[cmdname].first

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

  def test_bundle
    filenames = SINGLE_ARCHES.map { |a| fixture(a, "hellobundle.so") }

    filenames.each do |fn|
      file = MachO::MachOFile.new(fn)

      # a file can only be ONE of these
      assert file.bundle?
      filechecks(except = :bundle?).each do |check|
        refute file.send(check)
      end

      assert_equal "MH_BUNDLE", file.filetype

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

      assert file.segments.size > 0
      assert file.linked_dylibs.size > 0

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

      # compare actual and expected file hashes, to ensure file correctness
      assert equal_sha1_hashes(actual, expected)
    end
  ensure
    groups.each do |_, actual, _|
      delete_if_exists(actual)
    end
  end

  def test_change_rpath
    groups = SINGLE_ARCHES.map do |arch|
      ["", "_rpath_actual", "_rpath_expected"].map do |suffix|
        fixture(arch, "hello#{suffix}.bin")
      end
    end

    pass
  end
end
