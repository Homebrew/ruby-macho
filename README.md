ruby-macho
================

A Ruby library for manipulating Mach-O files.

### What is a Mach-O file?

The [Mach-O file format](https://en.wikipedia.org/wiki/Mach-O) is used by OS X
and iOS (among others) as a general purpose binary format for object files,
executables, dynamic libraries, and so forth.

### Slapped together documentation

Reading a file:

```ruby
require 'macho'

file = MachO::MachOFile.new("/path/to/my.dylib")
```

Getting basic file statistics/metadata:

```ruby
file.executable? # => false
file.dylib? # => true
file.bundle? # => false

file.magic_string # => MH_CIGAM_64
file.magic # => 0xcffaedfe
file.filetype # => MH_DYLIB
file.cputype # => CPU_TYPE_X86_64
file.cpusubtype # => CPU_SUBTYPE_X86_ALL
file.ncmds # => 15
file.sizeofcmds # => 1824
file.flags # => 2097285

file.dylib_id # => /path/to/my.dylib

# see lib/macho/file.rb for more attributes and accessors
```

Getting load commands by name:

```ruby
file['LC_SEGMENT_64'].each do |seg|
	puts seg.name
end # => __PAGEZERO, __TEXT, ...

# see lib/macho/load_commands.rb for each load command's fields
```

Changing file data:

```ruby
# for now, only changing the ID of a dylib is implemented:

file.dylib_id = "/new/path/to/my.dylib"
```

Writing a file:

```ruby
file.write("new.dylib")

file.write! # dangerous: overwrites the original file!
```

### What works?

* Reading *some* data from x86/x86_64 Mach-O files
* Changing the IDs of Mach-O dylibs

### What might work?

* Reading *some* data from PPC Mach-O files.

### What doesn't work yet?

* Reading data from Universal Mach-O files.
* Reading data from any other architecure's Mach-O files (probably).

### What needs to be done?

* Documentation.

Attribution:

* `lib/macho/cstruct.rb` was taken from Sami Samhuri's
[compiler](https://github.com/samsonjs/compiler) reposityory.
(No license provided).
* Constants in `lib/macho/macho.rb` were taken from Apple, Inc's
[`loader.h` in `cctools/include/mach-o`](http://www.opensource.apple.com/source/cctools/cctools-870/include/mach-o/loader.h).
(Apple Public Source License 2.0).
