# Struct does some trickery with custom allocators so we can't
# subclass it without writing C.  Instead we define a CStruct class
# that does something similar enough for our purpose.  It is
# subclassed just like any other class.  A nice side-effect of this
# syntax is that it is always clear that a CStruct is just a class and
# instances of the struct are objects.
#    
# Some light metaprogramming is used to make the following syntax possible:
#
# class MachHeader < CStruct
#   uint :magic
#   int  :cputype
#   int  :cpusubtype
#    ...
#   int  :flags
# end
#
# Inheritance works as you would expect.
#
# class LoadCommand < CStruct
#   uint32 :cmd
#   uint32 :cmdsize
# end
# 
# # inherits cmd and cmdsize as the first 2 fields
# class SegmentCommand < LoadCommand
#   string :segname, 16
#   uint32 :vmaddr
#   uint32 
# end
#
# Nothing tricky or confusing there.  Members of a CStruct class are
# declared in the class definition.  A different definition using a
# more static approach probably wouldn't be very hard...  if
# performance is critical ... but then why are you using Ruby? ;-)
#
#
# TODO support bit fields
#
# Bit fields should be supported by passing the number of bits a field
# should occupy. Perhaps we could use the size 'pack' for the rest of
# the field.
#
# class RelocationInfo < CStruct
#   int32  :address
#   uint32 :symbolnum, 24
#   pack   :pcrel,      1
#   pack   :length,     2
#   pack   :extern,     1
#   pack   :type,       4
# end

class CStruct


  ###################
  # Class Constants #
  ###################
  
  # Size in bytes.
  SizeMap = {
    :int8   => 1,
    :uint8  => 1,
    :int16  => 2,
    :uint16 => 2,
    :int32  => 4,
    :uint32 => 4,
    :string => lambda { |*opts| opts.first }, # first opt is size
    # the last 3 are to make the language more C-like
    :int    => 4,
    :uint   => 4,
    :char   => 1
  }

  # 32-bit
  PackMap = {
    :int8   => 'c',
    :uint8  => 'C',
    :int16  => 's',
    :uint16 => 'S',
    :int32  => 'i',
    :uint32 => 'I',
    :string => lambda do |str, *opts|
                        len = opts.first
                        str.ljust(len, "\0")[0, len]
                      end,
    # a few C-like names
    :int    => 'i',
    :uint   => 'I',
    :char   => 'C'
  }
  
  # Only needed when unpacking is different from packing, i.e. strings w/ lambdas in PackMap.
  UnpackMap = {
    :string => lambda do |str, *opts|
                        len = opts.first
                        val = str[0, len-1].sub(/\0*$/, '')
                        str.slice!((len-1)..-1)
                        val
                      end
  }
  
  ##########################
  # Class Instance Methods #
  ##########################
  
  # Note: const_get and const_set are used so the constants are bound
  #       at runtime, to the real class that has subclassed CStruct.
  #       I figured Ruby would do this but I haven't looked at the
  #       implementation of constants so it might be tricky.
  #
  #       All of this could probably be avoided with Ruby 1.9 and
  #       private class variables.  That is definitely something to
  #       experiment with.
  
  class <<self
    
    def inherited(subclass)
      subclass.instance_eval do
        
        # These "constants" are only constant references.  Structs can
        # be modified.  After the struct is defined it is still open,
        # but good practice would be not to change a struct after it
        # has been defined.
        # 
        # To support inheritance properly we try to get these
        # constants from the enclosing scope (and clone them before
        # modifying them!), and default to empty, er, defaults.
        
        members = const_get(:Members).clone rescue []
        member_index = const_get(:MemberIndex).clone rescue {}
        member_sizes = const_get(:MemberSizes).clone rescue {}
        member_opts = const_get(:MemberOptions).clone rescue {}
        
        const_set(:Members, members)
        const_set(:MemberIndex, member_index)
        const_set(:MemberSizes, member_sizes)
        const_set(:MemberOptions, member_opts)
        
      end
    end


    # Define a method for each size name, and when that method is called it updates
    # the struct class accordingly.
    SizeMap.keys.each do |type|
      
      define_method(type) do |name, *args|
        name = name.to_sym
        const_get(:MemberIndex)[name] = const_get(:Members).size
        const_get(:MemberSizes)[name] = type
        const_get(:MemberOptions)[name] = args
        const_get(:Members) << name
      end
      
    end
    
    
    # Return the number of members.
    def size
      const_get(:Members).size
    end
    alias_method :length, :size
    
    # Return the number of bytes occupied in memory or on disk.
    def bytesize
      const_get(:Members).inject(0) { |size, name| size + sizeof(name) }
    end
        
    def sizeof(name)
      value = SizeMap[const_get(:MemberSizes)[name]]
      value.respond_to?(:call) ? value.call(*const_get(:MemberOptions)[name]) : value
    end

    def new_from_bin(bin)
      new_struct = new
      new_struct.unserialize(bin)
    end

  end
  

  ####################
  # Instance Methods #
  ####################
  
  attr_reader :values
  
  def initialize(*args)
    @values = args
  end

  def serialize
    vals = @values.clone
    membs = members.clone
    pack_pattern.map do |patt|
      name = membs.shift
      if patt.is_a?(String)
        [vals.shift].pack(patt)
      else
        patt.call(vals.shift, *member_options[name])
      end      
    end.join
  end

  def unserialize(bin)
    bin = bin.clone
    @values = []
    membs = members.clone
    unpack_pattern.each do |patt|
      name = membs.shift
      if patt.is_a?(String)
        @values += bin.unpack(patt)
        bin.slice!(0, sizeof(name))
      else
        @values << patt.call(bin, *member_options[name])
      end
    end
    self
  end
  
  def pack_pattern
    members.map { |name| PackMap[member_sizes[name]] }
  end
  
  def unpack_pattern
    members.map { |name| UnpackMap[member_sizes[name]] || PackMap[member_sizes[name]] }
  end
  
  def [](name_or_idx)
    case name_or_idx
      
    when Numeric
      idx = name_or_idx
      @values[idx]
      
    when String, Symbol
      name = name_or_idx.to_sym
      @values[member_index[name]]
      
    else
      raise ArgumentError, "expected name or index, got #{name_or_idx.inspect}"
    end
  end
  
  def []=(name_or_idx, value)
    case name_or_idx
      
    when Numeric
      idx = name_or_idx
      @values[idx] = value
      
    when String, Symbol
      name = name_or_idx.to_sym
      @values[member_index[name]] = value
      
    else
      raise ArgumentError, "expected name or index, got #{name_or_idx.inspect}"
    end
  end
  
  def ==(other)
    puts @values.inspect
    puts other.values.inspect
    other.is_a?(self.class) && other.values == @values
  end

  # Some of these are just to quack like Ruby's built-in Struct.  YAGNI, but can't hurt either.

  def each(&block)
    @values.each(&block)
  end
  
  def each_pair(&block)
    members.zip(@values).each(&block)
  end
  
  def size
    members.size
  end
  alias_method :length, :size
  
  def sizeof(name)
    self.class.sizeof(name)
  end

  def bytesize
    self.class.bytesize
  end

  alias_method :to_a, :values


  # A few convenience methods.

  def members
    self.class::Members
  end
  
  def member_index
    self.class::MemberIndex
  end
  
  def member_sizes
    self.class::MemberSizes
  end
 
  def member_options
    self.class::MemberOptions
  end
 
  # The last expression is returned, so return self instead of junk.
  self  
end


# a small test
if $0 == __FILE__
  class MachHeader < CStruct
    uint :magic
    int  :cputype
    int  :cpusubtype
    string :segname, 16
  end
  puts MachHeader::Members.inspect
  puts MachHeader::MemberIndex.inspect
  puts MachHeader::MemberSizes.inspect
  puts "# of MachHeader members: " + MachHeader.size.to_s + ", size in bytes: " + MachHeader.bytesize.to_s
  mh = MachHeader.new(0xfeedface, 7, 3, "foobar")
  %w[magic cputype cpusubtype segname].each do |field|
    puts "#{field}(#{MachHeader.sizeof(field.to_sym)}):      #{mh[field.to_sym].inspect}"
  end
  puts mh.pack_pattern.inspect
  binstr = mh.serialize
  puts "values: " + mh.values.inspect
  newmh = MachHeader.new_from_bin(binstr)
  puts "new values: " + newmh.values.inspect
  newbinstr = newmh.serialize
  puts "serialized:   " + binstr.inspect
  puts "unserialized: " + newbinstr.inspect
  puts "new == old ? " + (newbinstr == binstr).to_s
end
