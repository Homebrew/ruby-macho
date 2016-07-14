module MachO
  module Utils
    # @param value [Fixnum] the number being rounded
    # @param round [Fixnum] the number being rounded with
    # @return [Fixnum] the next number >= `value` such that `round` is its divisor
    # @see http://www.opensource.apple.com/source/cctools/cctools-870/libstuff/rnd.c
    def self.round(value, round)
      round -= 1
      value += round
      value &= ~round
      value
    end

    # @param size [Fixnum] the unpadded size
    # @param alignment [Fixnum] the number to alignment the size with
    # @return [Fixnum] the number of pad bytes required
    def self.padding_for(size, alignment)
      round(size, alignment) - size
    end

    # Convert an abstract (native-endian) String#unpack format to big or little.
    # @param format [String] the format string being converted
    # @param endianness [Symbol] either `:big` or `:little`
    # @return [String] the converted string
    def self.specialize_format(format, endianness)
      modifier = (endianness == :big) ? ">" : "<"
      format.tr("=", modifier)
    end

    # @param fixed_offset [Fixnum] the baseline offset for the first packed string
    # @param alignment [Fixnum] the alignment value to use for packing
    # @param strings [Hash] the labeled strings to pack
    # @return Array<String, Hash> the packed string and labeled offsets
    def self.pack_strings(fixed_offset, alignment, strings = {})
      offsets = {}
      next_offset = fixed_offset
      payload = ""

      strings.each do |key, string|
        offsets[key] = next_offset
        payload << string
        payload << "\x00"
        next_offset += string.bytesize + 1
      end

      payload << "\x00" * padding_for(fixed_offset + payload.bytesize, alignment)
      [payload, offsets]
    end

    # @param num [Fixnum] the number being checked
    # @return [Boolean] true if `num` is a valid Mach-O magic number, false otherwise
    def self.magic?(num)
      MH_MAGICS.has_key?(num)
    end

    # @param num [Fixnum] the number being checked
    # @return [Boolean] true if `num` is a valid Fat magic number, false otherwise
    def self.fat_magic?(num)
      num == FAT_MAGIC
    end

    # @param num [Fixnum] the number being checked
    # @return [Boolean] true if `num` is a valid 32-bit magic number, false otherwise
    def self.magic32?(num)
      num == MH_MAGIC || num == MH_CIGAM
    end

    # @param num [Fixnum] the number being checked
    # @return [Boolean] true if `num` is a valid 64-bit magic number, false otherwise
    def self.magic64?(num)
      num == MH_MAGIC_64 || num == MH_CIGAM_64
    end

    # @param num [Fixnum] the number being checked
    # @return [Boolean] true if `num` is a valid little-endian magic number, false otherwise
    def self.little_magic?(num)
      num == MH_CIGAM || num == MH_CIGAM_64
    end

    # @param num [Fixnum] the number being checked
    # @return [Boolean] true if `num` is a valid big-endian magic number, false otherwise
    def self.big_magic?(num)
      num == MH_CIGAM || num == MH_CIGAM_64
    end
  end
end
