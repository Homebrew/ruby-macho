#!/usr/bin/env ruby

require './lib/macho'

file = MachO::MachOFile.new(ARGV.shift)
file.dylib_id = ARGV.shift
file.write("output.bin")
