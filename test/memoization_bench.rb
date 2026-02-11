# frozen_string_literal: true

require_relative "helpers"
require "benchmark/ips"

class MemoizationBenchmark
  include Helpers

  def run
    puts "=" * 80
    puts "Baseline Benchmarks for Memoization (Recommendation #1)"
    puts "=" * 80
    puts

    bench_linked_dylibs_single_call
    bench_linked_dylibs_repeated_calls
    bench_rpaths_single_call
    bench_rpaths_repeated_calls
    bench_dylib_load_commands_single_call
    bench_dylib_load_commands_repeated_calls
    bench_segments_single_call
    bench_segments_repeated_calls
    bench_command_lookup

    puts
    puts "=" * 80
    puts "Fat File Benchmarks"
    puts "=" * 80
    puts

    bench_fat_linked_dylibs_repeated_calls
    bench_fat_rpaths_repeated_calls
  end

  def bench_linked_dylibs_single_call
    filename = fixture(:x86_64, "libhello.dylib")

    puts "Benchmarking: linked_dylibs (single call)"
    Benchmark.ips do |bm|
      bm.report("linked_dylibs") do
        file = MachO.open(filename)
        file.linked_dylibs
      end
    end
    puts
  end

  def bench_linked_dylibs_repeated_calls
    filename = fixture(:x86_64, "libhello.dylib")

    puts "Benchmarking: linked_dylibs (10 repeated calls on same instance)"
    Benchmark.ips do |bm|
      bm.report("linked_dylibs x10") do
        file = MachO.open(filename)
        10.times { file.linked_dylibs }
      end
    end
    puts
  end

  def bench_rpaths_single_call
    filename = fixture(:x86_64, "hello.bin")

    puts "Benchmarking: rpaths (single call)"
    Benchmark.ips do |bm|
      bm.report("rpaths") do
        file = MachO.open(filename)
        file.rpaths
      end
    end
    puts
  end

  def bench_rpaths_repeated_calls
    filename = fixture(:x86_64, "hello.bin")

    puts "Benchmarking: rpaths (10 repeated calls on same instance)"
    Benchmark.ips do |bm|
      bm.report("rpaths x10") do
        file = MachO.open(filename)
        10.times { file.rpaths }
      end
    end
    puts
  end

  def bench_dylib_load_commands_single_call
    filename = fixture(:x86_64, "libhello.dylib")

    puts "Benchmarking: dylib_load_commands (single call)"
    Benchmark.ips do |bm|
      bm.report("dylib_load_commands") do
        file = MachO.open(filename)
        file.dylib_load_commands
      end
    end
    puts
  end

  def bench_dylib_load_commands_repeated_calls
    filename = fixture(:x86_64, "libhello.dylib")

    puts "Benchmarking: dylib_load_commands (10 repeated calls on same instance)"
    Benchmark.ips do |bm|
      bm.report("dylib_load_commands x10") do
        file = MachO.open(filename)
        10.times { file.dylib_load_commands }
      end
    end
    puts
  end

  def bench_segments_single_call
    filename = fixture(:x86_64, "libhello.dylib")

    puts "Benchmarking: segments (single call)"
    Benchmark.ips do |bm|
      bm.report("segments") do
        file = MachO.open(filename)
        file.segments
      end
    end
    puts
  end

  def bench_segments_repeated_calls
    filename = fixture(:x86_64, "libhello.dylib")

    puts "Benchmarking: segments (10 repeated calls on same instance)"
    Benchmark.ips do |bm|
      bm.report("segments x10") do
        file = MachO.open(filename)
        10.times { file.segments }
      end
    end
    puts
  end

  def bench_command_lookup
    filename = fixture(:x86_64, "libhello.dylib")

    puts "Benchmarking: command() lookup (repeated calls with different types)"
    Benchmark.ips do |bm|
      bm.report("command lookups x5") do
        file = MachO.open(filename)
        file.command(:LC_SEGMENT_64)
        file.command(:LC_DYLD_INFO_ONLY)
        file.command(:LC_SYMTAB)
        file.command(:LC_DYSYMTAB)
        file.command(:LC_LOAD_DYLINKER)
      end
    end
    puts
  end

  def bench_fat_linked_dylibs_repeated_calls
    filename = fixture(%i[i386 x86_64], "libhello.dylib")

    puts "Benchmarking: fat file linked_dylibs (10 repeated calls)"
    Benchmark.ips do |bm|
      bm.report("fat linked_dylibs x10") do
        file = MachO.open(filename)
        10.times { file.linked_dylibs }
      end
    end
    puts
  end

  def bench_fat_rpaths_repeated_calls
    filename = fixture(%i[i386 x86_64], "hello.bin")

    puts "Benchmarking: fat file rpaths (10 repeated calls)"
    Benchmark.ips do |bm|
      bm.report("fat rpaths x10") do
        file = MachO.open(filename)
        10.times { file.rpaths }
      end
    end
    puts
  end
end

if __FILE__ == $PROGRAM_NAME
  MemoizationBenchmark.new.run
end
