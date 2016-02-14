require "macho"
require "digest/sha1"
require "fileutils"

module Helpers
  TEST_OBJ = "test/bin/hello.o"
  TEST_EXE = "test/bin/hello.bin"
  TEST_DYLIB = "test/bin/libhello.dylib"
  TEST_EXTRA_DYLIB = "test/bin/libextrahello.dylib"
  TEST_BUNDLE = "test/bin/hellobundle.so"

  TEST_FAT_OBJ = "test/bin/fathello.o"
  TEST_FAT_EXE = "test/bin/fathello.bin"
  TEST_FAT_DYLIB = "test/bin/libfathello.dylib"
  TEST_FAT_EXTRA_DYLIB = "test/bin/libfatextrahello.dylib"
  TEST_FAT_BUNDLE = "test/bin/fathellobundle.so"

  OTOOL_RX = /\t(.*) \(compatibility version (?:\d+\.)*\d+, current version (?:\d+\.)*\d+\)/

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
end
