# frozen_string_literal: true

# if we're running the tests on the CI, generate a coverage report
if ENV["CI"]
  require "simplecov"
  require "simplecov-cobertura"
  SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
  SimpleCov.start
end

require "digest/sha1"
require "fileutils"
require "minitest/autorun"
require "tempfile"

require "macho"

module Helpers
  OTOOL_RX = /\t(.*) \(compatibility version (?:\d+\.)*\d+, current version (?:\d+\.)*\d+\)/.freeze

  # architectures used in testing 32-bit single-arch binaries
  SINGLE_32_ARCHES = %i[
    i386
    ppc
  ].freeze

  # architectures used in testing 64-bit single-arch binaries
  SINGLE_64_ARCHES = [
    :x86_64,
  ].freeze

  # architectures used in testing single-arch binaries
  SINGLE_ARCHES = SINGLE_32_ARCHES + SINGLE_64_ARCHES

  # architecture pairs used in testing fat binaries
  FAT_ARCH_PAIRS = [
    %i[i386 x86_64],
    %i[i386 ppc],
  ].freeze

  def fixture(archs, name)
    arch_dir = archs.is_a?(Array) ? "fat-#{archs.join("-")}" : archs.to_s
    "test/bin/#{arch_dir}/#{name}"
  end

  def installed?(util)
    !`which #{util}`.empty?
  end

  def delete_if_exists(file)
    FileUtils.rm_f(file)
  end

  def equal_sha1_hashes(file1, file2)
    digest1 = Digest::SHA1.file(file1).to_s
    digest2 = Digest::SHA1.file(file2).to_s

    digest1 == digest2
  end

  def filechecks(except = nil)
    checks = %i[
      object? executable? fvmlib? core? preload? dylib?
      dylinker? bundle? dsym? kext?
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
