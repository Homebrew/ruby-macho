# frozen_string_literal: true

module MachO
  # A general purpose pseudo-structure.
  # @abstract
  class MachOStructure
    @field_list = []
    @sizeof = 0
    @format = ""
    @mask_map = {}

    def initialize(*args)
      raise ArgumentError, "Invalid number of arguments" if args.size != self.class.field_list.size

      # Set up all instance variables
      self.class.field_list.zip(args).each do |field, value|
        value &= ~self.class.mask_map(field) if mask_map.key?(field)
        instance_variable_set("@#{field}", value)
      end
    end

    # @param name [Symbol] name of internal field
    # @param type [Symbol] type of field in terms of binary size
    # @param size [Int] an optional size parameter for string types
    # @api private
    def self.field(name, type, fmt:, size:, mask:)
      raise ArgumentError, "Invalid field type #{type}" unless type == :custom || BinPack::FORMAT_CODE.key?(type)
      raise ArgumentError, "Missing custom type arguments :fmt and/or :size" unless type != :custom && fmt && size
      raise ArgumentError, "Invalid field size #{size}" unless !size || size >= 0

      # Add new field attribute that will be initialized later
      attr_reader name

      # Add new field to list and calculate size and format
      @field_list << name
      @sizeof += size || BinPack::BYTE_SIZE[type]
      @format += fmt || BinPack::FORMAT_CODE[type]
      @mask_map[name] = mask if mask
    end

    def self.inherited(subclass)
      subclass.field_list = @field_list.clone
      subclass.sizeof = @sizeof.clone
      subclass.format = @format.clone
      subclass.mask_map = @mask_map.clone
    end

    class << self
      attr_reader :field_list, :sizeof, :format, :mask_map
      alias bytesize sizeof
    end

    # @param endianness [Symbol] either `:big` or `:little`
    # @param bin [String] the string to be unpacked into the new structure
    # @return [MachO::MachOStructure] the resulting structure
    # @api private
    def self.new_from_bin(endianness, bin)
      format = Utils.specialize_format(@format, endianness)

      new(*bin.unpack(format))
    end

    # @return [Hash] a hash representation of this {MachOStructure}.
    def to_h
      {
        "structure" => {
          "format" => self.class.format,
          "bytesize" => self.class.bytesize,
        },
      }
    end

    private

    # Needed for self.inherited method
    class << self
      attr_writer :field_list, :sizeof, :format, :mask_map
    end
  end
end
