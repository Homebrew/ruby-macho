# frozen_string_literal: true

module MachO
  module CodeSigning
    class CSStructure < MachOStructure
      attr_reader :view

      def self.new_from_bin(view)
        bin = view.raw_data.slice(view.offset, bytesize)
        format = Utils.specialize_format(self::FORMAT, view.endianness)

        new(view, *bin.unpack(format))
      end

      def initialize(view)
        @view = view
      end
    end

    class SuperBlob < CSStructure
      attr_reader :magic

      attr_reader :length

      attr_reader :count

      # NOTE(ww): SuperBlobs and other code signing structures appear to always be
      # big-endian for...reasons.
      FORMAT = "L>3"

      SIZEOF = 12

      def self.new_from_bin(view)
        bin = view.raw_data.slice(view.offset, bytesize)
        format = Utils.specialize_format(self::FORMAT, view.endianness)

        new(view, *bin.unpack(format))
      end

      def initialize(view, magic, length, count)
        # TODO(ww): Check magic matches CSMAGIC_EMBEDDED_SIGNATURE (0xfade0cc0)
        super(view)
        @magic = magic
        @length = length
        @count = count
      end

      def each_blob_index
        count.times do |i|
          index_offset = view.offset + self.class.bytesize + (BlobIndex.bytesize * i)
          blob_view = MachOView.new  view.raw_data, view.endianness, index_offset
          yield BlobIndex.new_from_bin blob_view
        end
      end
    end

    class BlobIndex < CSStructure
      attr_reader :type

      attr_reader :offset

      FORMAT = "L>2"

      SIZEOF = 8

      def initialize(view, type, offset)
        super(view)
        @type = type
        @offset = offset
      end
    end
  end
end
