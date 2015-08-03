#!/usr/bin/env ruby

require 'macho'

file = MachO::FatFile.new(ARGV.shift)

puts "No. architectures: #{file.fat_archs.size}"

file.machos.each do |macho|
	puts macho.cputype
end
