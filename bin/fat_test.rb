#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))

require "macho"

file = MachO::FatFile.new(ARGV.shift)

puts "No. architectures: #{file.fat_archs.size}"

file.machos.each do |macho|
  puts macho.cputype
end

puts "changing dylib id to test..."
file.dylib_id = "test"

file.write("libmacho_test.dylib")
