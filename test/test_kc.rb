# frozen_string_literal: true

require_relative "helpers"

BOOT_KERNEL_COLLECTION = "/System/Library/KernelCollections/BootKernelExtensions.kc"

if File.exist? BOOT_KERNEL_COLLECTION
  class KextCollectionTests < Minitest::Test
    include Helpers

    def test_load_kc
      MachO.open BOOT_KERNEL_COLLECTION
    end

    def test_navigate_fileset_command
      macho = MachO.open BOOT_KERNEL_COLLECTION

      fileset_entry = macho.command(:LC_FILESET_ENTRY).first
      assert(fileset_entry.segment)
    end
  end
end
