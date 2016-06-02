require "macho"
require "digest/sha1"
require "fileutils"
require "tempfile"

module Helpers
  OTOOL_RX = /\t(.*) \(compatibility version (?:\d+\.)*\d+, current version (?:\d+\.)*\d+\)/

  def fixture(archs, name)
    arch_dir = archs.is_a?(Array) ? "fat-#{archs.join("-")}" : archs.to_s
    "test/bin/#{arch_dir}/#{name}"
  end

  def installed?(util)
    !`which #{util}`.empty?
  end

  def delete_if_exists(file)
    if File.exist?(file)
      File.delete(file)
    end
  end

  def equal_sha1_hashes(file1, file2)
    digest1 = Digest::SHA1.file(file1).to_s
    digest2 = Digest::SHA1.file(file2).to_s

    digest1 == digest2
  end

  def filechecks(except = nil)
    checks = [
      :object?, :executable?, :fvmlib?, :core?, :preload?, :dylib?,
      :dylinker?, :bundle?, :dsym?, :kext?
    ]

    checks.delete(except)

    checks
  end

  def tempfile_with_data(filename, data)
    Tempfile.open(filename) do |file|
      file.write(data)
      file.rewind
      yield file
    end
  end
end
