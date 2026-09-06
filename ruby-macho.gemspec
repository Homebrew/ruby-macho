# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/lib/macho"

Gem::Specification.new do |s|
  s.name = "ruby-macho"
  s.version = MachO::VERSION
  s.summary = "Inspect and modify Mach-O files in pure Ruby"
  s.description = "A library for viewing and manipulating Mach-O files in Ruby."
  s.authors = ["William Woodruff"]
  s.email = "william@yossarian.net"
  s.files = Dir["lib/**/*.rb"] + %w[.yardopts CONTRIBUTING.md LICENSE README.md machostructure-dsl-docs.md]
  s.required_ruby_version = ">= 3.3"
  s.homepage = "https://github.com/Homebrew/ruby-macho"
  s.license = "MIT"
  s.metadata["rubygems_mfa_required"] = "true"
  s.metadata["source_code_uri"] = "https://github.com/Homebrew/ruby-macho"
  s.metadata["bug_tracker_uri"] = "https://github.com/Homebrew/ruby-macho/issues"
  s.metadata["documentation_uri"] = "https://www.rubydoc.info/gems/ruby-macho"
  s.metadata["changelog_uri"] = "https://github.com/Homebrew/ruby-macho/releases"
  s.metadata["funding_uri"] = "https://github.com/sponsors/Homebrew"
end
