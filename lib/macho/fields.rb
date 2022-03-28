# frozen_string_literal: true

module MachO
  # Constants used for parsing MachOStructure fields
  # that are found in the structure.rb file.
  module Fields
    # 1. All fields with empty strings and zeros aren't used
    #    to calculate the format and sizeof variables.
    # 2. All fields with nil should provide those values manually
    #    via the :size and :fmt parameters.

    # association of field types to byte size
    # @api private
    BYTE_SIZE = {
      :lcstr => 0,
      :view => 0,
      :bin_string => nil,
      :string => nil,
      :int32 => 4,
      :uint32 => 4,
      :uint32_net => 4,
      :uint64 => 8,
      :uint64_net => 8,
    }.freeze

    # association of field types with ruby format codes
    # Binary format codes can be found here:
    # https://docs.ruby-lang.org/en/2.6.0/String.html#method-i-unpack
    # @api private
    FORMAT_CODE = {
      :lcstr => "",
      :view => "",
      :bin_string => "a",
      :string => "Z",
      :int32 => "l",
      :uint32 => "L",
      :uint32_net => "L>", # Same as N
      :uint64 => "Q",
      :uint64_net => "Q>",
    }.freeze
  end
end
