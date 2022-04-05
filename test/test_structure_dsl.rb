# frozen_string_literal: true

require_relative "helpers"

class MachOStructureTest < Minitest::Test
  # Test that every field type can be created and that
  # that information is reflected in the bytesize, min_args
  # and format.
  class AllFields < MachO::MachOStructure
    field :binary, :binary, :size => 16
    field :string, :string, :size => 32
    field :int32, :int32
    field :uint32, :uint32
    field :uint64, :uint64
    field :view, :view
    field :lcstr, :lcstr
    field :two_level_hints_table, :two_level_hints_table
    field :tool_entries, :tool_entries
  end

  def test_all_field_types
    assert_includes AllFields.instance_methods, :binary
    assert_includes AllFields.instance_methods, :string
    assert_includes AllFields.instance_methods, :int32
    assert_includes AllFields.instance_methods, :uint32
    assert_includes AllFields.instance_methods, :uint64
    assert_includes AllFields.instance_methods, :view
    assert_includes AllFields.instance_methods, :lcstr
    assert_includes AllFields.instance_methods, :two_level_hints_table
    assert_includes AllFields.instance_methods, :tool_entries

    assert_equal AllFields.bytesize, 72
    assert_equal AllFields.format, "a16Z32l=L=Q=L=L="
    assert_equal AllFields.min_args, 8
  end

  # Test that fields already defined in the base class
  # are updated correctly when redefined in the
  # derived class.
  class BaseCmd < MachO::MachOStructure
    field :field1, :uint32
    field :field2, :uint32
  end

  class DerivedCmd < BaseCmd
    field :field1, :uint64
    field :field2, :uint64
  end

  def test_updating_fields
    assert_equal BaseCmd.bytesize, 8
    assert_equal BaseCmd.format, "L=L="
    assert_equal DerivedCmd.bytesize, 16
    assert_equal DerivedCmd.format, "Q=Q="
  end

  # Tests that make sure that all of the options work
  # correctly (except for :size which is already tested above).
  class MaskCmd < MachO::MachOStructure
    field :mask_field, :uint32, :mask => 0xffff0000
  end

  def test_mask_option
    mask_struct = MaskCmd.new(0xffffffff)
    assert_equal mask_struct.mask_field, 0x0000ffff
  end

  class UnpackCmd < MachO::MachOStructure
    field :unpack_field, :binary, :size => 8, :unpack => "L>2"
  end

  def test_unpack_option
    numbers = [42, 1337].freeze
    format_code = "L>2"
    packed_numbers = numbers.pack(format_code)

    unpack_struct = UnpackCmd.new(packed_numbers)
    assert_equal unpack_struct.unpack_field, numbers
  end

  class DefaultCmd < MachO::MachOStructure
    field :default_field, :uint64, :default => 0
  end

  def test_default_option
    default_struct = DefaultCmd.new
    assert_equal default_struct.default_field, 0
    default_struct = DefaultCmd.new(4)
    assert_equal default_struct.default_field, 4
  end

  class StringCmd < MachO::MachOStructure
    field :uint32, :uint32, :to_s => true
  end

  def test_to_s_option
    string_cmd = StringCmd.new(10)
    assert_equal string_cmd.to_s, "10"
  end

  class EndianCmd < MachO::MachOStructure
    field :uint32_big, :uint32, :endian => :big
    field :uint32_little, :uint32, :endian => :little
  end

  def test_endian_option
    assert_equal EndianCmd.format, "L>L<"
  end
end
