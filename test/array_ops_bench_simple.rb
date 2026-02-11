# frozen_string_literal: true

require_relative "helpers"
require "benchmark/ips"

class ArrayOpsSimpleBenchmark
  include Helpers

  def run
    puts "=" * 80
    puts "Array Operations Optimization - Before vs After"
    puts "=" * 80
    puts

    bench_linked_dylibs_isolated
    bench_rpaths_isolated
    bench_fat_operations_isolated
  end

  def bench_linked_dylibs_isolated
    filename = fixture(:x86_64, "libhello.dylib")
    file = MachO.open(filename)
    cmds = file.dylib_load_commands

    puts "Benchmarking: linked_dylibs - array operations only"
    Benchmark.ips do |bm|
      bm.report("BEFORE: map.map") do
        cmds.map(&:name).map(&:to_s).uniq
      end

      bm.report("AFTER:  single map") do
        cmds.map { |lc| lc.name.to_s }.uniq
      end

      bm.compare!
    end
    puts
  end

  def bench_rpaths_isolated
    filename = fixture(:x86_64, "hello.bin")
    file = MachO.open(filename)
    rpath_cmds = file.command(:LC_RPATH)

    puts "Benchmarking: rpaths - array operations only"
    Benchmark.ips do |bm|
      bm.report("BEFORE: map.map") do
        rpath_cmds.map(&:path).map(&:to_s)
      end

      bm.report("AFTER:  single map") do
        rpath_cmds.map { |lc| lc.path.to_s }
      end

      bm.compare!
    end
    puts
  end

  def bench_fat_operations_isolated
    filename = fixture(%i[i386 x86_64], "libhello.dylib")
    file = MachO.open(filename)
    machos = file.machos

    puts "Benchmarking: fat file operations - array operations only"
    Benchmark.ips do |bm|
      bm.report("BEFORE: map.flatten (dylib_load_commands)") do
        machos.map(&:dylib_load_commands).flatten
      end

      bm.report("AFTER:  flat_map (dylib_load_commands)") do
        machos.flat_map(&:dylib_load_commands)
      end

      bm.report("BEFORE: map.flatten.uniq (linked_dylibs)") do
        machos.map(&:linked_dylibs).flatten.uniq
      end

      bm.report("AFTER:  flat_map.uniq (linked_dylibs)") do
        machos.flat_map(&:linked_dylibs).uniq
      end

      bm.report("BEFORE: map.flatten.uniq (rpaths)") do
        machos.map(&:rpaths).flatten.uniq
      end

      bm.report("AFTER:  flat_map.uniq (rpaths)") do
        machos.flat_map(&:rpaths).uniq
      end

      bm.compare!
    end
    puts
  end
end

if __FILE__ == $PROGRAM_NAME
  ArrayOpsSimpleBenchmark.new.run
end
