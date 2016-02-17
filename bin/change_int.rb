#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))

require 'macho'

file = MachO::MachOFile.new(ARGV.shift)

file.change_install_name("/usr/lib/libSystem.B.dylib", "test")

file.write("output.bin")
