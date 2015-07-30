#!/usr/bin/env ruby

require 'macho'

file = MachO::MachOFile.new(ARGV.shift)
id = ARGV.shift.dup
file.dylib_id = id
file.write("output.bin")
