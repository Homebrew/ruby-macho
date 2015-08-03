#!/usr/bin/env ruby

require 'macho'

file = MachO::FatFile.new(ARGV.shift)

file.fat_archs.each do |arch|
	puts arch.inspect
end
