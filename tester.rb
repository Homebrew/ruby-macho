#!/usr/bin/env ruby

require './lib/macho'

file = MachO::MachOFile.new(ARGV.shift)

puts "FILE INFORMATION:"
puts "Header type: #{file.header.class}"
puts "Magic: #{file.magic}"
puts "Filetype: #{file.filetype}"
puts "CPU type: #{file.cputype}"
puts "CPU subtype: #{file.cpusubtype}"
puts "No. load commands: #{file.ncmds}"
puts "Size of load commands: #{file.sizeofcmds}"
puts "Flags: #{file.flags}"


puts "\nLOAD COMMANDS:"
file.load_commands.each do |lc|
	puts "#{lc} (#{lc.class}) (offset: #{lc.offset}, size: #{lc.cmdsize})"
end

puts "\nDYNAMIC LIBRARIES:"

puts "dylib ID: #{file.dylib_id}" if file.dylib?

puts file.linked_dylibs.join("\n")

puts "\nSEGMENTS AND SECTIONS:"

file['LC_SEGMENT_64'].each do |seg|
	puts "SEGMENT: #{seg.segment_name}"

	file.sections(seg).each do |sect|
		puts "\tSECTION: #{sect.section_name}"
		puts "\t\tOFFSET: #{sect.offset}"
	end
end

puts file['LC_DYSYMTAB'].first.inspect

#file.write("test.bin")
