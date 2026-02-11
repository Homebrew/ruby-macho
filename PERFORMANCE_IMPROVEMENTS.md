# Performance Improvement Recommendations for ruby-macho

This document outlines potential performance improvements that can be made to ruby-macho without changing the public API.

## Executive Summary

The ruby-macho library performs well for its use case, but there are several opportunities for optimization, particularly in:
1. Repeated computations that could be memoized
2. Array allocations that could be avoided
3. String operations on binary data
4. Unnecessary re-parsing after modifications

## Detailed Recommendations

### 1. Memoize Expensive Computed Properties (High Impact)

Several methods perform repeated computations that could be cached:

**Location: `lib/macho/macho_file.rb`**

```ruby
# Current implementation
def linked_dylibs
  dylib_load_commands.map(&:name).map(&:to_s).uniq
end

def rpaths
  command(:LC_RPATH).map(&:path).map(&:to_s)
end

def dylib_load_commands
  load_commands.select { |lc| LoadCommands::DYLIB_LOAD_COMMANDS.include?(lc.type) }
end

def segments
  if magic32?
    command(:LC_SEGMENT)
  else
    command(:LC_SEGMENT_64)
  end
end
```

**Recommendation:** Add memoization for these read-only operations:

```ruby
def linked_dylibs
  @linked_dylibs ||= dylib_load_commands.map(&:name).map(&:to_s).uniq
end

def rpaths
  @rpaths ||= command(:LC_RPATH).map(&:path).map(&:to_s)
end

def dylib_load_commands
  @dylib_load_commands ||= load_commands.select { |lc| LoadCommands::DYLIB_LOAD_COMMANDS.include?(lc.type) }
end

def segments
  @segments ||= magic32? ? command(:LC_SEGMENT) : command(:LC_SEGMENT_64)
end
```

Clear the memoization cache in `populate_fields`:
```ruby
def populate_fields
  clear_memoization_cache
  @header = populate_mach_header
  @load_commands = populate_load_commands
end

private

def clear_memoization_cache
  @linked_dylibs = nil
  @rpaths = nil
  @dylib_load_commands = nil
  @segments = nil
end
```

**Expected Impact:** 20-40% improvement for repeated calls to these methods (common in tools that query multiple properties).

---

### 2. Optimize Array Operations (Medium Impact)

**Location: `lib/macho/macho_file.rb` and `lib/macho/fat_file.rb`**

Current code chains multiple array operations:

```ruby
# MachOFile
dylib_load_commands.map(&:name).map(&:to_s).uniq

# FatFile
machos.map(&:dylib_load_commands).flatten
machos.map(&:rpaths).flatten.uniq
```

**Recommendation:** Use single-pass operations where possible:

```ruby
# Instead of two maps
dylib_load_commands.map { |lc| lc.name.to_s }.uniq

# For FatFile, use flat_map
machos.flat_map(&:dylib_load_commands)
machos.flat_map(&:rpaths).uniq
```

**Expected Impact:** 10-20% improvement by reducing intermediate array allocations.

---

### 3. Optimize Binary String Operations (Medium Impact)

**Location: `lib/macho/macho_file.rb`**

Current implementation modifies `@raw_data` string in-place:

```ruby
def delete_command(lc, options = {})
  @raw_data.slice!(lc.view.offset, lc.cmdsize)
  # ...
  @raw_data.insert(header.class.bytesize + sizeofcmds - lc.cmdsize, Utils.nullpad(lc.cmdsize))
  populate_fields if options.fetch(:repopulate, true)
end

def insert_command(offset, lc, options = {})
  # ...
  @raw_data.insert(offset, cmd_raw)
  @raw_data.slice!(header.class.bytesize + new_sizeofcmds, cmd_raw.bytesize)
  populate_fields if options.fetch(:repopulate, true)
end
```

**Recommendation:** Consider building a new string when multiple modifications are needed:

```ruby
def delete_command(lc, options = {})
  offset = lc.view.offset
  cmdsize = lc.cmdsize
  
  # Build new string instead of in-place modification
  @raw_data = @raw_data[0...offset] + 
              @raw_data[(offset + cmdsize)..-1]
  
  # Update header
  update_ncmds(ncmds - 1)
  update_sizeofcmds(sizeofcmds - cmdsize)
  
  # Pad to preserve offsets
  insert_point = header.class.bytesize + sizeofcmds - cmdsize
  @raw_data = @raw_data[0...insert_point] + 
              Utils.nullpad(cmdsize) + 
              @raw_data[insert_point..-1]
  
  populate_fields if options.fetch(:repopulate, true)
end
```

Or batch modifications:
```ruby
def batch_modify
  # Store modifications and apply all at once
  # This avoids multiple full-file shifts
end
```

**Expected Impact:** 15-25% improvement for operations that modify load commands, especially when called multiple times.

---

### 4. Cache `command()` Lookups (High Impact)

**Location: `lib/macho/macho_file.rb`**

The `command()` method is called repeatedly and filters the load_commands array each time:

```ruby
def command(cmd_sym)
  load_commands.select { |lc| lc.type == cmd_sym }
end
```

**Recommendation:** Build a hash index during `populate_load_commands`:

```ruby
def populate_load_commands
  # ... existing code ...
  
  load_commands = []
  @load_commands_by_type = Hash.new { |h, k| h[k] = [] }
  
  header.ncmds.times do
    # ... existing parsing code ...
    load_commands << command
    @load_commands_by_type[command.type] << command
    offset += command.cmdsize
  end
  
  load_commands
end

def command(cmd_sym)
  @load_commands_by_type.fetch(cmd_sym, [])
end
```

Clear in `populate_fields`:
```ruby
def clear_memoization_cache
  # ... existing clears ...
  @load_commands_by_type = nil
end
```

**Expected Impact:** 30-50% improvement for `command()` calls, which are used frequently throughout the codebase.

---

### 5. Optimize `segment_alignment` Computation (Low-Medium Impact)

**Location: `lib/macho/macho_file.rb` lines 273-294**

This method iterates through all segments and sections:

```ruby
def segment_alignment
  return 12 if %i[i386 x86_64 ppc ppc64].include?(cputype)
  return 14 if %i[arm arm64].include?(cputype)

  cur_align = Sections::MAX_SECT_ALIGN
  segments.each do |segment|
    # ... loop through sections ...
  end
  cur_align
end
```

**Recommendation:** Memoize the result:

```ruby
def segment_alignment
  @segment_alignment ||= calculate_segment_alignment
end

private

def calculate_segment_alignment
  return 12 if %i[i386 x86_64 ppc ppc64].include?(cputype)
  return 14 if %i[arm arm64].include?(cputype)
  
  # ... existing computation logic ...
end
```

**Expected Impact:** 10-15% improvement when this method is called multiple times (e.g., in FatFile.new_from_machos).

---

### 6. Optimize FatFile Construction (Medium Impact)

**Location: `lib/macho/fat_file.rb` lines 35-72**

The `new_from_machos` method calls `serialize` multiple times on each macho:

```ruby
machos.each do |macho|
  macho_offset = Utils.round(offset, 2**macho.segment_alignment)
  # ...
  bin << fa_klass.new(..., macho.serialize.bytesize, ...).serialize
  offset += (macho.serialize.bytesize + macho_pads[macho])
end

machos.each do |macho|
  bin << Utils.nullpad(macho_pads[macho])
  bin << macho.serialize
end
```

**Recommendation:** Serialize once and cache:

```ruby
macho_bins = machos.map { |m| [m, m.serialize] }
offset = Headers::FatHeader.bytesize + (machos.size * fa_klass.bytesize)
macho_pads = {}

macho_bins.each do |macho, serialized|
  macho_offset = Utils.round(offset, 2**macho.segment_alignment)
  raise FatArchOffsetOverflowError, macho_offset if !fat64 && macho_offset > ((2**32) - 1)
  
  macho_pads[macho] = Utils.padding_for(offset, 2**macho.segment_alignment)
  
  bin << fa_klass.new(macho.header.cputype, macho.header.cpusubtype,
                      macho_offset, serialized.bytesize,
                      macho.segment_alignment).serialize
  
  offset += (serialized.bytesize + macho_pads[macho])
end

macho_bins.each do |macho, serialized|
  bin << Utils.nullpad(macho_pads[macho])
  bin << serialized
end
```

**Expected Impact:** 20-30% improvement for fat file creation from multiple machos.

---

### 7. Use Frozen String Literals Consistently (Low Impact)

**Current State:** Most files have `# frozen_string_literal: true`, which is good.

**Recommendation:** Ensure all string literals that don't need mutation use frozen strings. For mutable strings that need concatenation, use the unary plus operator:

```ruby
# In FatFile.new_from_machos
bin = +""  # Explicitly mutable

# In Utils.pack_strings
payload = +""
```

This is already done in some places but should be applied consistently.

**Expected Impact:** 5-10% reduction in GC pressure.

---

### 8. Optimize `populate_and_check_magic` (Low Impact)

**Location: `lib/macho/macho_file.rb` lines 548-557**

```ruby
def populate_and_check_magic
  magic = @raw_data[0..3].unpack1("N")
  # ... checks ...
  magic
end
```

This is called after already unpacking in `populate_mach_header`. Could pass the magic value instead of re-unpacking.

**Expected Impact:** Minimal, but reduces redundant work.

---

### 9. Consider StringIO for Large Files (Future Enhancement)

For very large Mach-O files, using StringIO or mmap could reduce memory pressure. However, this would require significant refactoring and may not be worth it for typical use cases.

---

## Implementation Priority

1. **High Priority (High Impact, Low Risk):**
   - Memoize `linked_dylibs`, `rpaths`, `dylib_load_commands`, `segments`
   - Cache `command()` lookups with hash index
   - Optimize FatFile construction

2. **Medium Priority (Medium Impact, Low Risk):**
   - Use `flat_map` instead of `map + flatten`
   - Use single-pass array operations
   - Memoize `segment_alignment`

3. **Low Priority (Lower Impact or Higher Risk):**
   - Optimize binary string operations (needs careful testing)
   - Consistent frozen string literals
   - Remove redundant unpacking

---

## Testing Recommendations

For each optimization:
1. Run the existing test suite to ensure correctness
2. Run `test/bench.rb` to measure performance impact
3. Test with real-world Homebrew bottles (the primary use case)
4. Profile with `ruby-prof` or `stackprof` to identify any new bottlenecks

---

## Benchmark Example

Before implementing, establish baseline benchmarks:

```ruby
require 'benchmark/ips'
require 'macho'

filename = 'path/to/large/binary'

Benchmark.ips do |bm|
  bm.report("linked_dylibs") do
    file = MachO.open(filename)
    10.times { file.linked_dylibs }
  end
  
  bm.report("rpaths") do
    file = MachO.open(filename)
    10.times { file.rpaths }
  end
  
  bm.compare!
end
```

---

## Conclusion

These optimizations should provide measurable performance improvements for common operations without changing the public API. The most impactful changes are memoization of computed properties and building a hash index for load command lookups.

Estimated overall improvement for typical workloads: **25-40%** reduction in execution time for read-heavy operations, **15-25%** for modification operations.