#!/usr/bin/env ruby

require 'macho'

file = MachO::MachOFile.new(ARGV.shift)

puts "FILE INFORMATION:"
puts "Header type: #{file.header.class}"
puts "Magic: #{file.magic_string}"
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

puts "\nDYLIB ID: #{file.dylib_id}" if file.dylib?

puts "\nDYNAMIC LIBRARIES:"

puts file.linked_dylibs.join("\n")

puts "\nSEGMENTS AND SECTIONS:"

file.segments.each do |seg|
	puts "SEGMENT: #{seg.segment_name}"

	file.sections(seg).each do |sect|
		puts "\tSECTION: #{sect.section_name}"
		puts "\t\tOFFSET: #{sect.offset}"
	end
end
