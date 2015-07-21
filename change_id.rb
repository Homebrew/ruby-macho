#!/usr/bin/env ruby

require './lib/macho'

file = MachO::MachOFile.new(ARGV.shift)
id = ARGV.shift.dup
file.dylib_id = id
file.write("output.bin")
