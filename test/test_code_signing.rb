# frozen_string_literal: true

require_relative "helpers"

class MachOCodeSigningTest < Minitest::Test
  include Helpers

  def test_signs_an_unsigned_macho
    SINGLE_ARCHES.each do |arch|
      tempfile_with_data("hello", File.binread(fixture(arch, "hello.bin"))) do |file|
        old_path = ENV.fetch("PATH", nil)
        begin
          ENV["PATH"] = ""
          assert_nil MachO.codesign!(file.path)
        ensure
          ENV["PATH"] = old_path
        end

        assert_valid_ad_hoc_signature(MachO.open(file.path))
      end
    end
  end

  def test_replaces_an_existing_signature
    tempfile_with_data("hello", File.binread(fixture(:x86_64, "hello.bin"))) do |file|
      MachO.codesign!(file.path)
      first_signature = File.binread(file.path)

      MachO.codesign!(file.path)

      assert_equal first_signature, File.binread(file.path)
      assert_valid_ad_hoc_signature(MachO.open(file.path))
    end
  end

  def test_parses_and_enumerates_embedded_signature_data
    tempfile_with_data("hello", File.binread(fixture(:x86_64, "hello.bin"))) do |file|
      MachO.codesign!(file.path)
      parsed = MachO::CodeSigning::Blob.parse(
        MachO.open(file.path)[:LC_CODE_SIGNATURE].first.superblob.serialize
      )
      yielded_indices = []
      yielded_blobs = []

      parsed.each_blob_index { |index| yielded_indices << index }
      parsed.each_blob { |blob| yielded_blobs << blob }

      assert_instance_of MachO::CodeSigning::SuperBlob, parsed
      assert_equal parsed.indices, parsed.each_blob_index.to_a
      assert_equal parsed.indices, yielded_indices
      assert_equal parsed.blobs, parsed.each_blob.to_a
      assert_equal parsed.blobs, yielded_blobs
      assert_equal parsed.indices.map { |index| { "type" => index.type, "offset" => index.offset } },
                   parsed.to_h["indices"]
      assert_equal parsed.blobs.map(&:to_h), parsed.to_h["blobs"]
    end
  end

  def test_rejects_invalid_code_directory_hash_ranges
    options = {
      :identifier => "test",
      :hash_type => MachO::CodeSigning::CS_HASHTYPE_SHA256,
      :flags => MachO::CodeSigning::CS_ADHOC,
      :special_slots => {},
      :exec_seg_base => 0,
      :exec_seg_limit => 0,
      :exec_seg_flags => 0,
      :runtime => 0,
    }
    code_directory = MachO::CodeSigning::CodeDirectory.build("code", **options)
    zero_hash_size = code_directory.dup
    zero_hash_size.setbyte(36, 0)
    hash_before_header = code_directory.dup
    hash_before_header[16, 4] = [hash_before_header.unpack1("N", :offset => 20) - 1].pack("N")
    hashes_over_identifier = MachO::CodeSigning::CodeDirectory.build(
      "code", **options, :special_slots => { MachO::CodeSigning::CSSLOT_REQUIREMENTS => "requirements" }
    )
    hashes_over_identifier[16, 4] = [
      hashes_over_identifier.unpack1("N", :offset => 20) +
        (hashes_over_identifier.unpack1("N", :offset => 24) * hashes_over_identifier.getbyte(36)),
    ].pack("N")

    [zero_hash_size, hash_before_header, hashes_over_identifier].each do |malformed|
      error = assert_raises(MachO::CodeSigningError) do
        MachO::CodeSigning::CodeDirectory.new(malformed)
      end
      assert_equal "CodeDirectory hash range is invalid", error.message
    end
  end

  def test_derives_a_legacy_identifier_without_a_uuid
    macho = MachO.open(fixture(:x86_64, "hello.bin"))
    macho.delete_command(macho[:LC_UUID].first)
    digest = Digest::SHA1.new
    digest << macho.serialize.byteslice(0, MachO::Headers::MachHeader.bytesize)
    digest << macho.serialize.byteslice(macho.header.class.bytesize, macho.sizeofcmds)

    assert_equal "hello-#{digest.hexdigest}", MachO::CodeSigning.identifier(macho, "hello.bin")
  end

  def test_fills_an_empty_signature_command
    tempfile_with_data("hello", File.binread(fixture(:x86_64, "hello.bin"))) do |file|
      macho = MachO.open(file.path)
      macho.add_command(MachO::LoadCommands::LoadCommand.create(:LC_CODE_SIGNATURE, 0, 0))
      macho.write!

      MachO.codesign!(file.path)

      assert_equal 1, MachO.open(file.path)[:LC_CODE_SIGNATURE].size
      assert_valid_ad_hoc_signature(MachO.open(file.path))
    end
  end

  def test_preserves_the_inode_and_mode
    tempfile_with_data("hello", File.binread(fixture(:x86_64, "hello.bin"))) do |file|
      link = "#{file.path}.link"
      File.link(file.path, link)
      stat = File.stat(file.path)

      MachO.codesign!(file.path)

      assert_equal stat.ino, File.stat(file.path).ino
      assert_equal stat.mode, File.stat(file.path).mode
      assert_equal File.binread(file.path), File.binread(link)
    ensure
      FileUtils.rm_f(link)
    end
  end

  def test_macos_accepts_the_signature
    skip unless RUBY_PLATFORM.include?("darwin")

    tempfile_with_data("hello", File.binread(fixture(:x86_64, "hello.bin"))) do |file|
      MachO.codesign!(file.path)

      assert system("/usr/bin/codesign", "--verify", "--strict", file.path,
                    :out => File::NULL, :err => File::NULL)
    end
  end

  def test_signs_every_slice_in_a_fat_macho
    tempfile_with_data("hello", File.binread(fixture(%i[i386 x86_64], "hello.bin"))) do |file|
      MachO.codesign!(file.path)

      fat = MachO.open(file.path)
      fat.machos.each { |macho| assert_valid_ad_hoc_signature(macho) }
      fat.fat_archs.zip(fat.machos).each do |arch, macho|
        assert_equal macho.serialize.bytesize, arch.size
        assert_equal 0, arch.offset % (2**arch.align)
      end

      first_signature = fat.serialize
      MachO.codesign!(file.path)

      assert_equal first_signature, File.binread(file.path)
    end
  end

  def test_preserves_codesign_metadata
    tempfile_with_data("hello", File.binread(fixture(:x86_64, "hello.bin"))) do |file|
      MachO.codesign!(file.path)
      macho = MachO.open(file.path)
      command = macho[:LC_CODE_SIGNATURE].first
      entitlements = entitlement_blob
      requirements = [MachO::CodeSigning::CSMAGIC_REQUIREMENTS, 16, 0, "test"].pack("N3a4")
      code_directory = MachO::CodeSigning::CodeDirectory.build(
        macho.serialize.byteslice(0, command.dataoff),
        :identifier => "old-identifier",
        :hash_type => MachO::CodeSigning::CS_HASHTYPE_SHA256,
        :flags => MachO::CodeSigning::CS_ADHOC | MachO::CodeSigning::CS_HARD | MachO::CodeSigning::CS_RUNTIME,
        :special_slots => {
          MachO::CodeSigning::CSSLOT_REQUIREMENTS => requirements,
          MachO::CodeSigning::CSSLOT_ENTITLEMENTS => entitlements,
        },
        :exec_seg_base => 0,
        :exec_seg_limit => 4096,
        :exec_seg_flags => MachO::CodeSigning::CS_EXECSEG_MAIN_BINARY | MachO::CodeSigning::CS_EXECSEG_JIT,
        :runtime => 0x000d0000
      )
      superblob = MachO::CodeSigning::SuperBlob.build(
        MachO::CodeSigning::CSSLOT_CODEDIRECTORY => code_directory,
        MachO::CodeSigning::CSSLOT_REQUIREMENTS => requirements,
        MachO::CodeSigning::CSSLOT_ENTITLEMENTS => entitlements
      )
      assert_operator superblob.bytesize, :<=, command.datasize
      macho.serialize[command.dataoff, command.datasize] = superblob.ljust(command.datasize, "\x00")
      macho.write!

      MachO.codesign!(file.path)

      command = MachO.open(file.path)[:LC_CODE_SIGNATURE].first
      superblob = command.superblob
      code_directory = superblob.blobs.grep(MachO::CodeSigning::CodeDirectory).last
      assert_equal MachO::CodeSigning::CS_ADHOC | MachO::CodeSigning::CS_HARD | MachO::CodeSigning::CS_RUNTIME,
                   code_directory.flags
      assert_equal 0x000d0000, code_directory.runtime
      assert_equal MachO::CodeSigning::CS_EXECSEG_MAIN_BINARY | MachO::CodeSigning::CS_EXECSEG_JIT,
                   code_directory.exec_seg_flags
      assert_equal requirements, superblob.blob(MachO::CodeSigning::CSSLOT_REQUIREMENTS).serialize
      assert_equal entitlements, superblob.blob(MachO::CodeSigning::CSSLOT_ENTITLEMENTS).serialize
      assert_equal Digest::SHA256.digest(requirements),
                   code_directory.special_hash(MachO::CodeSigning::CSSLOT_REQUIREMENTS)
      assert_equal Digest::SHA256.digest(entitlements),
                   code_directory.special_hash(MachO::CodeSigning::CSSLOT_ENTITLEMENTS)
    end
  end

  def test_does_not_modify_a_file_when_signing_fails
    tempfile_with_data("hello.o", File.binread(fixture(:x86_64, "hello.o"))) do |file|
      original = File.binread(file.path)

      assert_raises MachO::CodeSigningError do
        MachO.codesign!(file.path)
      end

      assert_equal original, File.binread(file.path)
    end
  end

  def test_rejects_data_after_an_existing_signature
    tempfile_with_data("hello", File.binread(fixture(:x86_64, "hello.bin"))) do |file|
      MachO.codesign!(file.path)
      File.open(file.path, "ab") { |output| output.write("not part of the signature") }
      original = File.binread(file.path)

      assert_raises MachO::CodeSigningError do
        MachO.codesign!(file.path)
      end

      assert_equal original, File.binread(file.path)
    end
  end

  def test_rejects_duplicate_signature_commands
    tempfile_with_data("hello", File.binread(fixture(:x86_64, "hello.bin"))) do |file|
      macho = MachO.open(file.path)
      2.times do
        macho.add_command(MachO::LoadCommands::LoadCommand.create(:LC_CODE_SIGNATURE, 0, 0))
      end
      macho.write!
      original = File.binread(file.path)

      assert_raises MachO::CodeSigningError do
        MachO.codesign!(file.path)
      end

      assert_equal original, File.binread(file.path)
    end
  end

  private

  def entitlement_blob
    payload = "<?xml version=\"1.0\"?><plist><dict/></plist>"
    [MachO::CodeSigning::CSMAGIC_EMBEDDED_ENTITLEMENTS, payload.bytesize + 8].pack("N2") + payload
  end

  def assert_valid_ad_hoc_signature(macho)
    command = macho[:LC_CODE_SIGNATURE].first
    refute_nil command
    assert_equal 0, command.dataoff % 16
    assert_equal macho.serialize.bytesize, command.dataoff + command.datasize

    linkedit = macho.segments.find { |segment| segment.segname == "__LINKEDIT" }
    assert_equal macho.serialize.bytesize - linkedit.fileoff, linkedit.filesize
    assert_operator linkedit.vmsize, :>=, linkedit.filesize

    superblob = command.superblob
    assert_equal MachO::CodeSigning::CSMAGIC_EMBEDDED_SIGNATURE, superblob.magic
    assert_equal :CSMAGIC_EMBEDDED_SIGNATURE, superblob.magic_sym
    assert_equal superblob.indices.size, superblob.count
    assert_equal superblob.blobs.size, superblob.count

    code_directories = superblob.blobs.grep(MachO::CodeSigning::CodeDirectory)
    assert_includes [
      [MachO::CodeSigning::CS_HASHTYPE_SHA256],
      [MachO::CodeSigning::CS_HASHTYPE_SHA1, MachO::CodeSigning::CS_HASHTYPE_SHA256],
    ], code_directories.map(&:hash_type)

    requirements = superblob.blob(MachO::CodeSigning::CSSLOT_REQUIREMENTS)
    assert_equal MachO::CodeSigning::CSMAGIC_REQUIREMENTS, requirements.magic

    code_directories.each do |code_directory|
      refute_nil code_directory.hash_type_sym
      assert_equal MachO::CodeSigning::CS_ADHOC, code_directory.flags
      assert_equal command.dataoff, code_directory.code_limit
      assert_equal 12, code_directory.page_size
      assert_equal((command.dataoff + 4095) / 4096, code_directory.n_code_slots)

      digest = if code_directory.hash_type == MachO::CodeSigning::CS_HASHTYPE_SHA1
        Digest::SHA1
      else
        Digest::SHA256
      end
      0.step(command.dataoff - 1, 4096).with_index do |offset, slot|
        assert_equal digest.digest(macho.serialize.byteslice(offset, [4096, command.dataoff - offset].min)),
                     code_directory.code_hash(slot)
      end
      assert_equal digest.digest(requirements.serialize),
                   code_directory.special_hash(MachO::CodeSigning::CSSLOT_REQUIREMENTS)
    end
  end
end
