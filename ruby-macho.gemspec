require "#{File.dirname(__FILE__)}/lib/macho"

Gem::Specification.new do |s|
  s.name = "ruby-macho"
  s.version = MachO::VERSION
  s.summary = "ruby-macho - Mach-O file analyzer."
  s.description = "A library for viewing and manipulating Mach-O files in Ruby."
  s.authors = ["William Woodruff"]
  s.email = "william@tuffbizz.com"
  s.files = Dir["LICENSE", "README.md", ".yardopts", "lib/**/*"]
  s.homepage = "https://github.com/Homebrew/ruby-macho"
  s.license = "MIT"
end
