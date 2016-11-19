#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))

require "macho"

file = MachO::MachOFile.new(ARGV.shift)
id = ARGV.shift.dup
file.dylib_id = id
file.write("output.bin")
