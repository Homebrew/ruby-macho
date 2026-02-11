# frozen_string_literal: true

require_relative "helpers"
require "benchmark/ips"

class ArrayOpsBenchmark
  include Helpers

  def run
    puts "=" * 80
    puts "Baseline Benchmarks for Array Operations (Recommendation #2)"
    puts "=" * 80
    puts

    bench_linked_dylibs_chained_maps
    bench_rpaths_chained_maps
    bench_fat_dylib_load_commands_flatten
    bench_fat_linked_dylibs_flatten
    bench_fat_rpaths_flatten

    puts
    puts "=" * 80
    puts "Array Operations Only (without file I/O overhead)"
    puts "=" * 80
    puts

    bench_array_ops_only_linked_dylibs
    bench_array_ops_only_rpaths
    bench_array_ops_only_fat_flatten

    puts
    puts "=" * 80
    puts "Comparison: Manual flat_map vs map.flatten"
    puts "=" * 80
    puts

    bench_flat_map_comparison
  end

  def bench_linked_dylibs_chained_maps
    filename = fixture(:x86_64, "libhello.dylib")

    puts "Benchmarking: linked_dylibs (chained .map.map pattern)"
    Benchmark.ips do |bm|
      bm.report("current (map.map)") do
        file = MachO.open(filename)
        file.linked_dylibs
      end

      bm.report("optimized (single map)") do
        file = MachO.open(filename)
        file.dylib_load_commands.map { |lc| lc.name.to_s }.uniq
      end

      bm.compare!
    end
    puts
  end

  def bench_rpaths_chained_maps
    filename = fixture(:x86_64, "hello.bin")

    puts "Benchmarking: rpaths (chained .map.map pattern)"
    Benchmark.ips do |bm|
      bm.report("current (map.map)") do
        file = MachO.open(filename)
        file.rpaths
      end

      bm.report("optimized (single map)") do
        file = MachO.open(filename)
        file.command(:LC_RPATH).map { |lc| lc.path.to_s }
      end

      bm.compare!
    end
    puts
  end

  def bench_fat_dylib_load_commands_flatten
    filename = fixture(%i[i386 x86_64], "libhello.dylib")

    puts "Benchmarking: fat file dylib_load_commands (map.flatten)"
    Benchmark.ips do |bm|
      bm.report("current (map.flatten)") do
        file = MachO.open(filename)
        file.dylib_load_commands
      end

      bm.report("optimized (flat_map)") do
        file = MachO.open(filename)
        file.machos.flat_map(&:dylib_load_commands)
      end

      bm.compare!
    end
    puts
  end

  def bench_fat_linked_dylibs_flatten
    filename = fixture(%i[i386 x86_64], "libhello.dylib")

    puts "Benchmarking: fat file linked_dylibs (map.flatten.uniq)"
    Benchmark.ips do |bm|
      bm.report("current (map.flatten)") do
        file = MachO.open(filename)
        file.linked_dylibs
      end

      bm.report("optimized (flat_map)") do
        file = MachO.open(filename)
        file.machos.flat_map(&:linked_dylibs).uniq
      end

      bm.compare!
    end
    puts
  end

  def bench_fat_rpaths_flatten
    filename = fixture(%i[i386 x86_64], "hello.bin")

    puts "Benchmarking: fat file rpaths (map.flatten.uniq)"
    Benchmark.ips do |bm|
      bm.report("current (map.flatten)") do
        file = MachO.open(filename)
        file.rpaths
      end

      bm.report("optimized (flat_map)") do
        file = MachO.open(filename)
        file.machos.flat_map(&:rpaths).uniq
      end

      bm.compare!
    end
    puts
  end

  def bench_array_ops_only_linked_dylibs
    filename = fixture(:x86_64, "libhello.dylib")
    file = MachO.open(filename)
    cmds = file.dylib_load_commands

    puts "Benchmarking: linked_dylibs array ops only (pre-loaded file)"
    Benchmark.ips do |bm|
      bm.report("current (map.map)") do
        cmds.map(&:name).map(&:to_s).uniq
      end

      bm.report("optimized (single map)") do
        cmds.map { |lc| lc.name.to_s }.uniq
      end

      bm.compare!
    end
    puts
  end

  def bench_array_ops_only_rpaths
    filename = fixture(:x86_64, "hello.bin")
    file = MachO.open(filename)
    rpath_cmds = file.command(:LC_RPATH)

    puts "Benchmarking: rpaths array ops only (pre-loaded file)"
    Benchmark.ips do |bm|
      bm.report("current (map.map)") do
        rpath_cmds.map(&:path).map(&:to_s)
      end

      bm.report("optimized (single map)") do
        rpath_cmds.map { |lc| lc.path.to_s }
      end

      bm.compare!
    end
    puts
  end

  def bench_array_ops_only_fat_flatten
    filename = fixture(%i[i386 x86_64], "libhello.dylib")
    file = MachO.open(filename)
    machos = file.machos

    puts "Benchmarking: fat file flatten ops only (pre-loaded file)"
    Benchmark.ips do |bm|
      bm.report("current (map.flatten)") do
        machos.map(&:dylib_load_commands).flatten
      end

      bm.report("optimized (flat_map)") do
        machos.flat_map(&:dylib_load_commands)
      end

      bm.compare!
    end
    puts
  end

  def bench_flat_map_comparison
    # Test with a simple array to show the difference
    data = [1, 2, 3, 4, 5] * 100

    puts "Benchmarking: flat_map vs map.flatten (synthetic test)"
    Benchmark.ips do |bm|
      bm.report("map.flatten") do
        data.map { |n| [n, n * 2] }.flatten
      end

      bm.report("flat_map") do
        data.flat_map { |n| [n, n * 2] }
      end

      bm.compare!
    end
    puts
  end
end

if __FILE__ == $PROGRAM_NAME
  ArrayOpsBenchmark.new.run
end
