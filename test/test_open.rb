require "minitest/autorun"
require "helpers"
require "macho"

class MachOOpenTest < Minitest::Test
  include Helpers

  def test_nonexistent_file
    assert_raises ArgumentError do
      MachO.open("/this/is/a/file/that/cannot/possibly/exist")
    end
  end

  # MachO.open has slightly looser qualifications for truncation than
  # either MachOFile.new or FatFile.new - it just makes sure that there are
  # enough magic bytes to read, and lets the actual parser raise a
  # TruncationError later on if required.
  def test_truncated_file
    tempfile_with_data("truncated_file", "\x00\x00") do |truncated_file|
      assert_raises MachO::TruncatedFileError do
        MachO.open(truncated_file.path)
      end
    end
  end

  def test_bad_magic
    tempfile_with_data("junk_file", "\xFF\xFF\xFF\xFF") do |junk_file|
      assert_raises MachO::MagicError do
        MachO.open(junk_file.path)
      end
    end
  end

  def test_open
    file = MachO.open("test/bin/libhello.dylib")

    assert_kind_of MachO::MachOFile, file

    file = MachO.open("test/bin/libfathello.dylib")

    assert_kind_of MachO::FatFile, file
  end
end
