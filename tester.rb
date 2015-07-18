#!/usr/bin/env ruby

require './lib/macho'

file = MachO::File.new(ARGV.shift)

puts "Header type: #{file.header.class}"
puts "Magic: #{file.magic}"
puts "Filetype: #{file.filetype}"
puts "CPU type: #{file.cputype}"
puts "CPU subtype: #{file.cpusubtype}"
puts "No. load commands: #{file.ncmds}"
puts "Size of load commands: #{file.sizeofcmds}"
puts "Flags: #{file.flags}"


puts "\n==== LOAD COMMANDS ===="
file.load_commands.each do |lc|
	puts "#{MachO::LOAD_COMMANDS[lc[:cmd]]} (#{lc[:cmdsize]} bytes)"
end
puts "======================="

puts "dylib ID: #{file.dylib_id}" if file.dylib?
