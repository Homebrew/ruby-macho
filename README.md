ruby-macho
================

[![Gem Version](https://badge.fury.io/rb/ruby-macho.svg)](http://badge.fury.io/rb/ruby-macho)
[![CI](https://github.com/Homebrew/ruby-macho/actions/workflows/tests.yml/badge.svg)](https://github.com/Homebrew/ruby-macho/actions/workflows/tests.yml)
[![Coverage Status](https://codecov.io/gh/Homebrew/ruby-macho/branch/master/graph/badge.svg)](https://codecov.io/gh/Homebrew/ruby-macho)

A Ruby library for examining and modifying Mach-O files.

### What is a Mach-O file?

The [Mach-O file format](https://en.wikipedia.org/wiki/Mach-O) is used by macOS
and iOS (among others) as a general purpose binary format for object files,
executables, dynamic libraries, and so forth.

### Installation

ruby-macho can be installed via RubyGems:

```bash
$ gem install ruby-macho
```

### Documentation

Full documentation is available on [RubyDoc](http://www.rubydoc.info/gems/ruby-macho/).

A quick example of what ruby-macho can do:

```ruby
require 'macho'

file = MachO::MachOFile.new("/path/to/my/binary")

# get the file's type (object, dynamic lib, executable, etc)
file.filetype # => :execute

# get all load commands in the file and print their offsets:
file.load_commands.each do |lc|
  puts "#{lc.type}: offset #{lc.offset}, size: #{lc.cmdsize}"
end

# access a specific load command
lc_vers = file[:LC_VERSION_MIN_MACOSX].first
puts lc_vers.version_string # => "10.10.0"
```

### What works?

* Reading data from x86/x86_64/PPC Mach-O files
* Changing the IDs of Mach-O and Fat dylibs
* Changing install names in Mach-O and Fat files
* Adding, deleting, and modifying rpaths.

### What needs to be done?

* Unit and performance testing.

### Contributing, setting up `overcommit` and the linters

In order to keep the repo, docs and data tidy, we use a tool called [`overcommit`](https://github.com/sds/overcommit)
to connect up the git hooks to a set of quality checks.  The fastest way to get setup is to run the following to make
sure you have all the tools:

```shell
gem install overcommit bundler
bundle install
overcommit --install
```

### Attribution

* Constants were taken from Apple, Inc's
[`loader.h` in `cctools/include/mach-o`](https://opensource.apple.com/source/cctools/cctools-973.0.1/include/mach-o/loader.h.auto.html).
(Apple Public Source License 2.0).
* Binary files used for testing were taken from The LLVM Project. ([Apache License v2.0 with LLVM Exceptions](test/bin/llvm/LICENSE.txt)).

### License

`ruby-macho` is licensed under the MIT License.

For the exact terms, see the [license](LICENSE) file.
