# frozen_string_literal: true

module MachO
  # A general purpose pseudo-structure.
  # @abstract
  class MachOStructure
    # Constants used for parsing MachOStructure fields
    module Fields
      # 1. All fields with empty strings and zeros aren't used
      #    to calculate the format and sizeof variables.
      # 2. All fields with nil should provide those values manually
      #    via the :size and :fmt parameters.

      # association of field types to byte size
      # @api private
      BYTE_SIZE = {
        # Binary slices
        :bin_string => nil,
        :string => nil,
        :int32 => 4,
        :uint32 => 4,
        :uint32_net => 4,
        :uint64 => 8,
        :uint64_net => 8,
        # Classes
        :view => 0,
        :lcstr => 4,
        :two_level_hints_table => 0,
        :tool_entries => 4,
      }.freeze

      # association of field types with ruby format codes
      # Binary format codes can be found here:
      # https://docs.ruby-lang.org/en/2.6.0/String.html#method-i-unpack
      #
      # The equals sign is used to manually change endianness using
      # the Utils#specialize_format() method.
      # @api private
      FORMAT_CODE = {
        # Binary slices
        :bin_string => "a",
        :string => "Z",
        :int32 => "l=",
        :uint32 => "L=",
        :uint32_net => "L>", # Same as N
        :uint64 => "Q=",
        :uint64_net => "Q>",
        # Classes
        :view => "",
        :lcstr => "L=",
        :two_level_hints_table => "",
        :tool_entries => "L=",
      }.freeze

      # a list of classes that must be initialized separately
      # in the constructor
      CLASS_LIST = %i[lcstr two_level_hints_table tool_entries].freeze
    end

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
    # @param args [Array[Value]] list of field parameters
    def initialize(*args)
      raise ArgumentError, "Invalid number of arguments" if args.size < self.class.min_args

      # Set up all instance variables
      self.class.field_list.zip(args).each do |field, value|
        # TODO: Find a better way to specialize initialization for certain types

        # Handle special cases
        type = self.class.type_map[field]
        if Fields::CLASS_LIST.include?(type)
          case type
          when :lcstr
            value = LoadCommands::LoadCommand::LCStr.new(self, value)
          when :two_level_hints_table
            value = LoadCommands::TwolevelHintsCommand::TwolevelHintsTable.new(view, htoffset, nhints)
          when :tool_entries
            value = LoadCommands::BuildVersionCommand::ToolEntries.new(view, value)
          end
        elsif self.class.option_map.key?(field)
          options = self.class.option_map[field]

          if options.key?(:mask)
            value &= ~options[:mask]
          elsif options.key?(:unpack)
            value = value.unpack(options[:unpack])
          elsif value.nil? && options.key?(:default)
            value = options[:default]
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
    #   :size [Integer] size in bytes
    #   :mask [Integer] bitmask
    #   :unpack [String] string format
    #   :default [Value] default value
    # @api private
    def self.field(name, type, **options)
      raise ArgumentError, "Invalid field type #{type}" unless Fields::FORMAT_CODE.key?(type)

      if type_map.key?(name)
        @min_args -= 1 unless @option_map.dig(name, :default)

        @option_map.delete(name) if options.empty?
      else
        attr_reader name

        # TODO: Should be able to generate #to_s based on presence of LCStr which is the 90% case
        # TODO: Could try generating #to_h for the 90% perecent case
        # Might be best to make another functional called maybe generate

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
      format = Utils.specialize_format(self.format, endianness)

      new(*bin.unpack(format))
    end

    def self.format
      @format ||= field_list.map do |field|
        Fields::FORMAT_CODE[type_map[field]] +
          option_map.dig(field, :size).to_s
      end.join
    end

    def self.bytesize
      @bytesize ||= field_list.map do |field|
        Fields::BYTE_SIZE[type_map[field]] ||
          option_map.dig(field, :size)
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
