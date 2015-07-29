Gem::Specification.new do |s|
	s.name = 'ruby-macho'
	s.version = '0.0.1'
	s.date = '2015-07-29'
	s.summary = 'ruby-macho - Mach-O file analyzer.'
	s.description = 'A library for viewing and manipulating Mach-O files in Ruby.'
	s.authors = ['William Woodruff']
	s.email = 'william@tuffbizz.com'
	s.files = [
		'lib/cstruct.rb',
		'lib/int_helpers.rb',
		'lib/otool_helpers.rb',
		'lib/macho.rb',
		'lib/macho/exceptions.rb',
		'lib/macho/file.rb',
		'lib/macho/headers.rb',
		'lib/macho/load_commands.rb',
		'lib/macho/sections.rb',
		'lib/macho/structure.rb',
		'lib/macho/utils.rb'
	]
	s.homepage = 'https://github.com/woodruffw/ruby-macho'
	s.license = 'MIT'
end
