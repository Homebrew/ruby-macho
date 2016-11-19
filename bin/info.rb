#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))

require "macho"

# Usage: bin/info.rb [--fat|--macho] <file>
arg1 = ARGV.shift
file = case arg1
when "--fat"
  MachO::FatFile.new(ARGV.shift) # Force fat binary.
when "--macho"
  MachO::MachOFile.new(ARGV.shift) # Force Mach-O binary.
else
  MachO.open(arg1) # Auto-detect fat/Mach-O binary.
end

if file.is_a?(MachO::FatFile)
  puts "NOTE: File is a fat binary with #{file.machos.size} architectures."
  puts "NOTE: Only showing information for the first architecture."
  puts
  file = file.machos.first
end

puts "FILE INFORMATION:"
puts "  Header type: #{file.header.class}"
puts "  Magic: #{file.magic_string}"
puts "  Filetype: #{file.filetype}"
puts "  CPU type: #{file.cputype}"
puts "  CPU subtype: #{file.cpusubtype}"
puts "  No. load commands: #{file.ncmds}"
puts "  Size of load commands: #{file.sizeofcmds}"
puts "  Flags: #{file.flags}"

puts "\nLOAD COMMANDS:"
file.load_commands.each do |lc|
  puts "  #{lc} (#{lc.class}) (offset: #{lc.offset}, size: #{lc.cmdsize})"
end

puts "\nDYLIB ID: #{file.dylib_id}" if file.dylib?

puts "\nDYNAMIC LIBRARIES:"
puts "  #{file.linked_dylibs.join("\n  ")}"

puts "\nSEGMENTS AND SECTIONS:"

file.segments.each do |seg|
  puts "  Segment: #{seg.segname} " \
       "(offset: #{seg.fileoff}, size: #{seg.filesize})"

  file.sections(seg).each do |sect|
    puts "    Section: #{sect.section_name} " \
         "(offset: #{sect.offset}, size: #{sect.size})"
  end
end
