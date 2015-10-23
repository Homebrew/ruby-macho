ruby-macho
================

[![Gem Version](https://badge.fury.io/rb/ruby-macho.svg)](http://badge.fury.io/rb/ruby-macho)
[![Build Status](https://drone.io/github.com/woodruffw/ruby-macho/status.png)](https://drone.io/github.com/woodruffw/ruby-macho/latest)

A Ruby library for manipulating Mach-O files.

### What is a Mach-O file?

The [Mach-O file format](https://en.wikipedia.org/wiki/Mach-O) is used by OS X
and iOS (among others) as a general purpose binary format for object files,
executables, dynamic libraries, and so forth.

### Documentation

Documentation is available [on rubydoc](http://www.rubydoc.info/gems/ruby-macho/).

### What works?

* Reading data from x86/x86_64 Mach-O files
* Changing the IDs of Mach-O dylibs
* Changing install names in Mach-O files

### What might work?

* Reading *some* data from PPC Mach-O files.
* Reading data from "Fat" files.

### What doesn't work yet?

* Reading data from any other architecure's Mach-O files (probably).
* Changing anything in "Fat" files (at least not correctly).

### What needs to be done?

* Documentation.
* Rpath modification.
* Many, many things.

Attribution:

* `lib/macho/cstruct.rb` was taken from Sami Samhuri's
[compiler](https://github.com/samsonjs/compiler) repository.
(No license provided).
* Constants in `lib/macho/macho.rb` were taken from Apple, Inc's
[`loader.h` in `cctools/include/mach-o`](http://www.opensource.apple.com/source/cctools/cctools-870/include/mach-o/loader.h).
(Apple Public Source License 2.0).

### License

`ruby-macho` is licensed under the MIT License.

For the exact terms, see the [license](LICENSE) file.
