#!/usr/bin/env ruby

#	otool.rb

require './lib/macho/macho'
require './lib/otool_helpers'

puts MachO.load_file
