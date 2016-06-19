ruby-macho
================

[![Gem Version](https://badge.fury.io/rb/ruby-macho.svg)](http://badge.fury.io/rb/ruby-macho)
[![Build Status](https://travis-ci.org/Homebrew/ruby-macho.svg?branch=master)](https://travis-ci.org/Homebrew/ruby-macho)

A Ruby library for examining and modifying Mach-O files.

### What is a Mach-O file?

The [Mach-O file format](https://en.wikipedia.org/wiki/Mach-O) is used by OS X
and iOS (among others) as a general purpose binary format for object files,
executables, dynamic libraries, and so forth.

### Documentation

**Important**: ruby-macho does not have a stable API (yet). Use it with this
in mind.

Full documentation is available on [RubyDoc](http://www.rubydoc.info/gems/ruby-macho/).

A quick example of what ruby-macho can do:

```ruby
require 'macho'

file = MachO::MachOFile.new("/path/to/my/binary")

# get the file's type (object, dynamic lib, executable, etc)
file.filetype # => :execute

# get all load commands in the file and print their offsets:
file.load_commands.each do |lc|
  puts "#{lc}: offset #{lc.offset}, size: #{lc.cmdsize}"
end

# access a specific load command
lc_vers = file[:LC_VERSION_MIN_MACOSX].first
puts lc_vers.version_string # => "10.10.0"
```

### What works?

* Reading data from x86/x86_64/PPC Mach-O files
* Changing the IDs of Mach-O and Fat dylibs
* Changing install names in Mach-O and Fat files

### What doesn't work yet?

* Adding, deleting, or modifying rpaths.

### What needs to be done?

* Documentation.
* Rpath modification.
* Many, many things.

Attribution:

* Constants were taken from Apple, Inc's
[`loader.h` in `cctools/include/mach-o`](http://www.opensource.apple.com/source/cctools/cctools-870/include/mach-o/loader.h).
(Apple Public Source License 2.0).

### License

`ruby-macho` is licensed under the MIT License.

For the exact terms, see the [license](LICENSE) file.
