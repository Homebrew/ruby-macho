#!/usr/bin/env ruby

require 'macho'

file = MachO::MachOFile.new(ARGV.shift)

file.change_install_name("/usr/lib/libSystem.B.dylib", "test")

file.write("output.bin")
