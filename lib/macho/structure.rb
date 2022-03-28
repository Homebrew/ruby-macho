# frozen_string_literal: true

require_relative "fields"

module MachO
  # A general purpose pseudo-structure.
  # @abstract
  class MachOStructure
    # map of field names to field types
    @type_map = {}

    # array of field name in definition order
    @field_list = []

    # map of field options
    @option_map = {}

    # minimum number of required arguments
    @min_args = 0

    class << self
      # Public getters
      attr_reader :type_map, :field_list, :option_map, :min_args

      private

      # Private setters
      attr_writer :type_map, :field_list, :option_map, :min_args
    end

    # Used to dynamically create an instance of the inherited class
    # according to the defined fields.
    # @param args [Array[x]] list of field parameters
    def initialize(*args)
      raise ArgumentError, "Invalid number of arguments" if args.size < self.class.min_args

      # Set up all instance variables
      self.class.field_list.zip(args).each do |field, value|
        # Handle special cases
        if type_map[field] == :lcstr
          value = LCStr.new(self, value)
        elsif self.class.option_map.key?(field)
          options = self.class.option_map[field]

          if options.key?(:mask)
            value &= ~options[:mask]
          elsif options.key?(:unpack)
            value = value.unpack(options[:unpack])
          elsif options.key?(:default)
            value = options[:default] if value.nil?
          end
        end

        instance_variable_set("@#{field}", value)
      end
    end

    # @param subclass [Class] subclass type
    # @api private
    def self.inherited(subclass)
      # Clone all class instance variables
      type_map = @type_map.dup
      field_list = @field_list.dup
      option_map = @option_map.dup
      min_args = @min_args.dup

      # Add those values to the inheriting class
      subclass.class_eval do
        @type_map = type_map
        @field_list = field_list
        @option_map = option_map
        @min_args = min_args
      end
    end

    # @param name [Symbol] name of internal field
    # @param type [Symbol] type of field in terms of binary size
    # @param options [Hash] set of additonal options
    # Expected options
    #   :size [Int] size in bytes
    #   :mask [Int] bitmask
    #   :unpack [String] string format
    #   :default [Value] default value
    # @api private
    def self.field(name, type, **options)
      raise ArgumentError, "Invalid field type #{type}" unless Fields::FORMAT_CODE.key?(type)

      if type_map.key?(name)
        @min_args += 1 if @option_map.dig(name, :default)

        @option_map.delete(name) if options.empty?
      else
        attr_reader name

        @field_list << name
      end

      @option_map[name] = options unless options.empty?
      @min_args += 1 unless options.key?(:default)
      @type_map[name] = type
    end

    # @param endianness [Symbol] either `:big` or `:little`
    # @param bin [String] the string to be unpacked into the new structure
    # @return [MachO::MachOStructure] the resulting structure
    # @api private
    def self.new_from_bin(endianness, bin)
      format = Utils.specialize_format(@format, endianness)

      new(*bin.unpack(format))
    end

    def self.format
      @format ||= @field_list.map do |field|
        FIELDS::FORMAT_CODE[@type_map[field]]
      end.join
    end

    def self.bytesize
      @bytesize ||= @field_list.map do |field|
        Fields::BYTE_SIZE[@type_map[field]] ||
          @option_map[field][:size]
      end.sum
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
