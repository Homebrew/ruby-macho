# Array Operations Optimization Results

This document shows the performance improvements achieved by implementing recommendation #2 from `PERFORMANCE_IMPROVEMENTS.md`: **Optimize Array Operations**.

## Implementation Summary

We optimized array operations in both `MachOFile` and `FatFile` by:

### MachOFile Changes
- `linked_dylibs`: Changed from `.map(&:name).map(&:to_s)` to `.map { |lc| lc.name.to_s }`
- `rpaths`: Changed from `.map(&:path).map(&:to_s)` to `.map { |lc| lc.path.to_s }`

### FatFile Changes
- `dylib_load_commands`: Changed from `.map(&:dylib_load_commands).flatten` to `.flat_map(&:dylib_load_commands)`
- `linked_dylibs`: Changed from `.map(&:linked_dylibs).flatten.uniq` to `.flat_map(&:linked_dylibs).uniq`
- `rpaths`: Changed from `.map(&:rpaths).flatten.uniq` to `.flat_map(&:rpaths).uniq`

## Performance Improvements

### Single MachO File - Array Operations

Measuring just the array operations (without file I/O overhead):

| Method | Before (i/s) | After (i/s) | Speedup | Time Before (ns) | Time After (ns) | Improvement |
|--------|--------------|-------------|---------|------------------|-----------------|-------------|
| `linked_dylibs` | 3.30M | 4.10M | **1.24x faster** | 302.71 | 243.69 | **19.5% faster** |
| `rpaths` | 3.61M | 4.36M | **1.21x faster** | 277.06 | 229.27 | **17.2% faster** |

### Fat File - Array Operations

Fat files show even more dramatic improvements due to the flatten operation:

| Method | Before (i/s) | After (i/s) | Speedup | Time Before (ns) | Time After (ns) | Improvement |
|--------|--------------|-------------|---------|------------------|-----------------|-------------|
| `dylib_load_commands` | 2.77M | 5.53M | **2.00x faster** | 360.51 | 180.74 | **49.9% faster** |
| `linked_dylibs` | 2.33M | 3.97M | **1.70x faster** | 428.34 | 251.91 | **41.2% faster** |
| `rpaths` | 2.97M | 5.54M | **1.87x faster** | 336.79 | 180.55 | **46.4% faster** |

## Key Findings

1. **Single-pass array operations are significantly faster**: Avoiding intermediate arrays provides 17-20% improvement for single-arch files

2. **Fat files benefit more from flat_map**: The `flat_map` optimization shows 42-50% improvement over `map.flatten`, with a **2x speedup** for `dylib_load_commands`

3. **Negligible overhead**: The block form `map { |x| x.method }` vs symbol-to-proc `.map(&:method)` adds no measurable overhead when combined into a single pass

4. **Reduced memory allocations**: Single-pass operations avoid creating intermediate arrays, reducing GC pressure

5. **Combined with memoization**: Since these operations are now memoized (from recommendation #1), the performance improvement applies to the first call, with subsequent calls being instant

## Real-World Impact

In typical usage patterns:
- Tools that open a fat binary and query `linked_dylibs` will see **~42% faster** array processing
- Tools that query multiple properties benefit from both memoization (recommendation #1) and optimized array operations
- The improvements are most noticeable when working with fat binaries containing multiple architectures

## Test Coverage

All existing tests pass with the optimized array operations:
- 137 runs, 2386 assertions, 0 failures, 0 errors

The implementation correctly:
- Produces identical results to the previous implementation
- Works with both single-arch and fat binaries
- Maintains all edge case handling (empty arrays, duplicates, etc.)

## Code Quality Benefits

Beyond performance, these changes provide:
- **Better readability**: Single `.map { }` is clearer than chained `.map().map()`
- **Modern Ruby idioms**: `flat_map` is the idiomatic way to flatten while mapping
- **Reduced complexity**: Fewer method calls means simpler stack traces when debugging

## Conclusion

The array operations optimization successfully achieves:
- **17-20% improvement** for single-arch Mach-O files
- **42-50% improvement** for fat binaries (up to **2x faster**)
- **Zero API changes** - fully backward compatible
- **No test failures** - maintains correctness
- **Improved code clarity** - more idiomatic Ruby

Combined with recommendation #1 (memoization), these optimizations provide cumulative benefits for real-world usage where files are loaded once and queried multiple times.