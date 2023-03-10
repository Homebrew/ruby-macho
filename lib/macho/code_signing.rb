# frozen_string_literal: true

module MachO
  module CodeSigning
    CS_STRUCTURES = {
      Headers::CSMAGIC_REQUIREMENT => "Requirement",
      Headers::CSMAGIC_REQUIREMENTS => "Requirements",
      Headers::CSMAGIC_CODEDIRECTORY => "CodeDirectory",
      Headers::CSMAGIC_EMBEDDED_SIGNATURE => "EmbeddedSignature",
      Headers::CSMAGIC_EMBEDDED_SIGNATURE_OLD => "OldEmbeddedSignature",
      Headers::CSMAGIC_DETACHED_SIGNATURE => "DetachedSignature",
      Headers::CSMAGIC_ENTITLEMENT => "Entitlement",
      Headers::CSMAGIC_ENTITLEMENTDER => "DEREntitlement",
      Headers::CSMAGIC_BLOBWRAPPER => "BlobWrapper",
    }.freeze

    CS_HASHTYPES = {
      1 => :CS_HASHTYPE_SHA1,
      2 => :CS_HASHTYPE_SHA256,
      3 => :CS_HASHTYPE_SHA256_TRUNCATED,
      4 => :CS_HASHTYPE_SHA384,
    }.freeze

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

      def to_h
        {
          "view" => view.to_h,
        }.merge super
      end
    end

    class CSBlob < CSStructure
      field :magic, :uint32, endian: :big
      field :length, :uint32, endian: :big

      def magic_sym
        Headers::CS_MAGICS[magic]
      end

      def to_h
        {
          "blob" => {
            "magic" => magic,
            "magic_sym" => magic_sym,
            "length" => length,
          },
        }.merge super
      end
    end

    class SuperBlob < CSBlob
      class BlobIndex < CSStructure
        field :type, :uint32, endian: :big
        field :offset, :uint32, endian: :big
      end

      field :count, :uint32, endian: :big

      def self.new_from_bin(view)
        bin = view.raw_data.slice(view.offset, bytesize)
        format = Utils.specialize_format(self::FORMAT, view.endianness)

        new(view, *bin.unpack(format))
      end

      def initialize(view, magic, length, count)
        # TODO(ww): Check magic matches CSMAGIC_EMBEDDED_SIGNATURE (0xfade0cc0)
        super(view, magic, length)
        @count = count
      end

      def each_blob_index
        count.times do |i|
          index_offset = view.offset + self.class.bytesize + (BlobIndex.bytesize * i)
          blob_view = MachOView.new view.raw_data, view.endianness, index_offset
          yield BlobIndex.new_from_bin blob_view
        end
      end

      def each_blob
        each_blob_index do |blob_index|
          blob_offset = view.offset + blob_index.offset
          blob_magic = view.raw_data[blob_offset, blob_offset + 4].unpack1("L>1")

          blob_klass_str = CS_STRUCTURES[blob_magic]
          raise CSBlobUnknownError, blob_magic unless blob_klass_str

          blob_klass = CodeSigning.const_get blob_klass_str
          blob_view = MachOView.new view.raw_data, view.endianness, blob_offset
          yield blob_klass.new_from_bin blob_view
        end
      end

      def to_h
        {
          magic_sym.to_h => {
            "count" => count,
          },
        }.merge super
      end
    end

    # Represents a code signing Requirement blob.
    class Requirement < CSBlob
    end

    # Represents a code signing Requirements vector.
    class Requirements < CSBlob
    end

    # Represents a code signing CodeDirectory blob.
    class CodeDirectory < CSBlob
      attr_reader :version
      attr_reader :flags
      attr_reader :hash_offset
      attr_reader :ident_offset
      attr_reader :n_special_slots
      attr_reader :n_code_slots
      attr_reader :code_limit
      attr_reader :hash_size
      attr_reader :hash_type
      attr_reader :spare1
      attr_reader :page_size
      attr_reader :spare2

      FORMAT = "L>9C4L>1"

      SIZEOF = 44

      def initialize(view, magic, length, version, flags, hash_offset,
                     ident_offset, n_special_slots, n_code_slots, code_limit,
                     hash_size, hash_type, spare1, page_size, spare2)
        super(view, magic, length)
        @version = version
        @flags = flags
        @hash_offset = hash_offset
        @ident_offset = ident_offset
        @n_special_slots = n_special_slots
        @n_code_slots = n_code_slots
        @code_limit = code_limit
        @hash_size = hash_size
        @hash_type = hash_type
        @spare1 = spare1
        @page_size = page_size
        @spare2 = spare2
      end

      def hash_type_sym
        CS_HASHTYPES[hash_type]
      end

      # TODO(ww): Figure out a good way to handle the fields that have been
      # added with different CodeDirectory versions:
      # * 0x20100:
      #   uint32_t scatterOffset
      #   char end_withScatter[0]
      # * 0x20200:
      #   uint32_t teamOffset
      #   char end_withTeam[0]
      # * 0x20300:
      #   uint32_t spare3
      #   uint64_t codeLimit64
      #   char end_withCodeLimit64[0]
      # * 0x20400:
      #   uint64_t execSegBase
      #   uint64_t execSegLimit
      #   uint64_t execSegFlags
      #   char end_withExecSec[0]

      def to_h
        {
          magic_sym.to_s => {
            "version" => version,
            "flags" => flags,
            "hash_offset" => hash_offset,
            "ident_offset" => ident_offset,
            "n_special_slots" => n_special_slots,
            "n_code_slots" => n_code_slots,
            "code_limit" => code_limit,
            "hash_size" => hash_size,
            "hash_type" => hash_type,
            "spare1" => spare1,
            "page_size" => page_size,
            "spare2" => spare2,
          },
        }.merge super
      end
    end

    # Represents a code signing EmbeddedSignature blob.
    class EmbeddedSignature < CSBlob
    end

    # Maybe represents an "old" embedded signature blob.
    # Not documented.
    class OldEmbeddedSignature < CSBlob
    end

    # Represents a multi-arch collection of embedded signatures.
    class DetachedSignature < CSBlob
    end

    # Represents a code signing Entitlement blob.
    class Entitlement < CSBlob
      # NOTE(ww): This appears to just have one member, data, whose length
      # is defined by attr :length.
      # From SecTask.c:
      # const struct theBlob {
      #   uint32_t magic;  /* kSecCodeMagicEntitlement */
      #   uint32_t length;
      #   const uint8_t data[];
      # }
    end

    class DEREntitlement < CSBlob
    end

    class BlobWrapper < CSBlob
    end
  end
end
