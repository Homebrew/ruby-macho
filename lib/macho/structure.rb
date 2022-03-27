# frozen_string_literal: true

module MachO
  # A general purpose pseudo-structure.
  # @abstract
  class MachOStructure
    # array of fields in definition order
    @field_list = []

    # total size of binary chunk
    @bytesize = 0

    # binary format string
    @format = ""

    # map of bitmasks
    @mask_map = {}

    class << self
      # Public getters
      attr_reader :bytesize, :format, :field_list, :mask_map

      private

      # Private setters
      attr_writer :bytesize, :format, :field_list, :mask_map
    end

    # Used to dynamically create an instance of the inherited class
    # according to the defined fields.
    # @param args [Array[x]] list of field parameters
    def initialize(*args)
      raise ArgumentError, "Invalid number of arguments" if args.size != self.class.field_list.size

      # Set up all instance variables
      self.class.field_list.zip(args).each do |field, value|
        value = LCStr.new(self, value) if field == :lcstr
        value &= ~self.class.mask_map[field] if self.class.mask_map.key?(field)

        instance_variable_set("@#{field}", value)
      end
    end

    # @param subclass [Class] subclass type
    # @api private
    def self.inherited(subclass)
      # Clone all class instance variables
      field_list = @field_list.clone
      bytesize = @bytesize.clone
      fmt = @format.clone
      mask_map = @mask_map.clone

      # Add those values to the inheriting class
      subclass.class_eval do
        @field_list = field_list
        @bytesize = bytesize
        @format = fmt
        @mask_map = mask_map
      end
    end

    # @param name [Symbol] name of internal field
    # @param type [Symbol] type of field in terms of binary size
    # @param fmt [String] optional binary format for custom types
    # @param size [Int] optional size parameter for custom types
    # @param mask [Int] optional bitmask
    # @api private
    def self.field(name, type, fmt:, size:, mask:)
      raise ArgumentError, "Invalid field type #{type}" unless Fields::FORMAT_CODE.key?(type)
      raise ArgumentError, "Missing custom type arguments :fmt and/or :size" if type == :custom && fmt && size

      # Add new field attribute that will be initialized later
      attr_reader name

      # Add new field to list and calculate size and format
      @field_list << name
      @bytesize += Fields::BYTE_SIZE[type] || size
      @format += Fields::FORMAT_CODE[type] || fmt
      @mask_map[name] = mask if mask
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
  end
end
