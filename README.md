ruby-macho
================

### What works?

* Reading *some* data from x86/x86_64 Mach-O files
* Changing the IDs of Mach-O dylibs

### What might work?

* Reading *some* data from PPC Mach-O files.

### What doesn't work yet?

* Reading data from Universal Mach-O files.
* Reading data from any other architecure's Mach-O files (probably).

Attribution:

* `lib/macho/cstruct.rb` was taken from Sami Samhuri's
[compiler](https://github.com/samsonjs/compiler) reposityory.
(No license provided).
* Constants in `lib/macho/macho.rb` were taken from Apple, Inc's
[`loader.h` in `cctools/include/mach-o`](http://www.opensource.apple.com/source/cctools/cctools-870/include/mach-o/loader.h).
(Apple Public Source License 2.0).
