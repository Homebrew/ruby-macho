# frozen_string_literal: true

module MachO
  # Constants for parsing Ruby binary packing constants
  module BinPack
    # association of field types to byte size
    # @api private
    BYTE_SIZE = {
      :bin_string => 0, # Size should be provided by subclass
      :string => 0,     # Size should be provided by subclass
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
      :bin_string => "a",
      :string => "Z",
      :int32 => "l",
      :uint32 => "L",
      :uint32_net => "L>",
      :uint64 => "Q",
      :uint64_net => "Q>",
    }.freeze
  end
end
