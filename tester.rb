#!/usr/bin/env ruby

require './lib/macho'

file = MachO::File.new("as.bin")

puts "Header type: #{file.header.class}"
puts "Magic: #{file.magic}"
puts "Filetype: #{file.filetype}"
puts "CPU type: #{file.cputype}"
puts "CPU subtype: #{file.cpusubtype}"
puts "No. load commands: #{file.ncmds}"
