ruby-macho
================

[![Gem Version](https://badge.fury.io/rb/ruby-macho.svg)](http://badge.fury.io/rb/ruby-macho)
[![CI](https://github.com/Homebrew/ruby-macho/actions/workflows/tests.yml/badge.svg)](https://github.com/Homebrew/ruby-macho/actions/workflows/tests.yml)
[![Coverage Status](https://codecov.io/gh/Homebrew/ruby-macho/branch/main/graph/badge.svg)](https://codecov.io/gh/Homebrew/ruby-macho)

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

### Ad-hoc code signing

Changing a Mach-O load command invalidates any existing code signature. This is
especially important when Homebrew pours bottles on Apple Silicon, where native
code must remain signed after its paths are rewritten. `MachO.codesign!` creates
the required ad-hoc signature in Ruby instead of invoking `/usr/bin/codesign`:

```ruby
MachO.codesign!("/path/to/my/binary")
```

The implementation follows the public structures used by
[XNU](https://github.com/apple-oss-distributions/xnu/blob/main/osfmk/kern/cs_blobs.h)
and [ld64](https://github.com/apple-oss-distributions/ld64). For each thin
Mach-O slice it adds or replaces `LC_CODE_SIGNATURE`, resizes `__LINKEDIT` then
hashes the final pre-signature bytes in 4 KiB pages. It emits a SHA-256
CodeDirectory, adding a SHA-1 alternate only when the declared deployment target
requires legacy hash agility. Fat binaries are signed one slice at a time then
laid out again with updated architecture offsets and sizes.

When replacing a non-linker signature, the signer preserves its requirements,
entitlements, flags, runtime version and executable-segment flags. Linker
signatures use fresh ad-hoc metadata, matching Apple's replacement behaviour.
Code-signing blobs use their mandated big-endian representation independently
of the Mach-O byte order, while the load command retains the slice byte order.

The complete signature is built and validated before the file is written. This
leaves the on-disk file unchanged on validation errors, while the final in-place
write preserves its inode, mode and hard links. Adding a missing load command
requires 16 bytes of existing header padding; ruby-macho raises
`MachO::CodeSigningError` rather than moving segments when that space is absent.
Only ad-hoc signing is provided: certificate identities, Developer ID signing,
notarisation and policy assessment remain outside ruby-macho's scope. See
[issue #262](https://github.com/Homebrew/ruby-macho/issues/262) for the original
design discussion.

### What works?

* Reading data from x86/x86_64/arm64/PPC Mach-O files (other architectures are unsupported, but may work)
* Changing the IDs of Mach-O and Fat dylibs
* Changing install names in Mach-O and Fat files
* Adding, deleting, and modifying rpaths.
* Parsing embedded code signatures and applying ad-hoc signatures in pure Ruby.

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
* Code-signing constants and structures follow Apple, Inc's
[`cs_blobs.h` in XNU](https://github.com/apple-oss-distributions/xnu/blob/main/osfmk/kern/cs_blobs.h).
* Binary files used for testing were taken from The LLVM Project. ([Apache License v2.0 with LLVM Exceptions](test/bin/llvm/LICENSE.txt)).

### License

`ruby-macho` is licensed under the MIT License.

For the exact terms, see the [license](LICENSE) file.
