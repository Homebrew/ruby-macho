# Internal MachOStructure DSL
## Documentation
The MachOStructure class makes it easy to describe binary chunks by using the #field method. This method generates the byte size and format strings necessary to parse a chunk of binary data. It also automatically generates the constructor and readers for all fields as well.

The fields are created in order so you will be expected to pass those arguments to the constructor in the same order. Fields with no arguments should be defined last and fields with default arguments should be defined right before them.

The type and options of inherited fields can be changed but their argument position and the number of arguments (used to calculate min_args) will also not change.

Usually, endianness is handled by the Utils#specialize_format method but occasionally a field needs to specify that beforehand. That is what the :endian option is for. If not specified, a placeholder is used so that can be specified later.

## Syntax
```ruby
field [field name], [field type], [option1 => value1], [option2 => value2], ...
```

## Example
```ruby
class AllFields < MachO::MachOStructure
  field :name1, :string, :size => 16
  field :name3, :int32
  field :name4, :uint32
  field :name5, :uint64
  field :name6, :view
  field :name7, :lcstr
  field :name8, :two_level_hints_table
  field :name9, :tool_entries
end
```

## Field Types
- `:string` [requires `:size` option] [optional `:padding` option]
  - a string
- `:int32 `
  - a signed 32 bit integer
- `:uint32 `
  - an unsigned 32 bit integer
- `:uint64 `
  - an unsigned 64 bit integer
- `:view` [initialized]
  - an instance of the MachOView class (lib/macho/view.rb)
- `:lcstr` [NOT initialized]
  - an instance of the LCStr class (lib/macho/load_commands.rb)
- `:two_level_hints_table` [NOT initialized] [NO argument]
  - an instance of the TwoLevelHintsTable class (lib/macho/load_commands.rb)
- `:tool_entries` [NOT initialized]
  - an instance of the ToolEntries class (lib/macho/load_commands.rb)

## Option Types
- Exclusive (only one can be used at a time)
  - `:mask` [Integer] bitmask to be applied to field
  - `:unpack` [String] binary unpack string used for further unpacking of :string
  - `:default` [Value] default field value
- Inclusive (can be used with other options)
  - `:to_s` [Boolean] generate `#to_s` method based on field
- Used with Integer field types
  - `:endian` [Symbol] optionally specify `:big` or `:little` endian
- Used with `:string` field type
  - `:size` [Integer] size in bytes
  - `:padding` [Symbol] optionally specify `:null` padding

## More Information
Hop over to lib/macho/structure.rb to see the class itself.
