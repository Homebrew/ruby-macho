# frozen_string_literal: true

require_relative "helpers"
require "benchmark/ips"

class CommandLookupBenchmark
  include Helpers

  def run
    puts "=" * 80
    puts "Baseline Benchmarks for command() Lookup (Recommendation #4)"
    puts "=" * 80
    puts

    bench_single_command_lookup
    bench_multiple_command_lookups
    bench_repeated_same_command
    bench_command_lookup_in_methods
  end

  def bench_single_command_lookup
    filename = fixture(:x86_64, "libhello.dylib")
    file = MachO.open(filename)

    puts "Benchmarking: single command() lookup"
    Benchmark.ips do |bm|
      bm.report("command(:LC_SEGMENT_64)") do
        file.command(:LC_SEGMENT_64)
      end

      bm.report("command(:LC_DYLD_INFO_ONLY)") do
        file.command(:LC_DYLD_INFO_ONLY)
      end

      bm.report("command(:LC_SYMTAB)") do
        file.command(:LC_SYMTAB)
      end

      bm.report("command(:LC_RPATH)") do
        file.command(:LC_RPATH)
      end
    end
    puts
  end

  def bench_multiple_command_lookups
    filename = fixture(:x86_64, "libhello.dylib")
    file = MachO.open(filename)

    puts "Benchmarking: multiple different command() lookups"
    Benchmark.ips do |bm|
      bm.report("5 different commands") do
        file.command(:LC_SEGMENT_64)
        file.command(:LC_DYLD_INFO_ONLY)
        file.command(:LC_SYMTAB)
        file.command(:LC_DYSYMTAB)
        file.command(:LC_LOAD_DYLINKER)
      end
    end
    puts
  end

  def bench_repeated_same_command
    filename = fixture(:x86_64, "libhello.dylib")
    file = MachO.open(filename)

    puts "Benchmarking: repeated lookups of same command"
    Benchmark.ips do |bm|
      bm.report("command(:LC_SEGMENT_64) x10") do
        10.times { file.command(:LC_SEGMENT_64) }
      end
    end
    puts
  end

  def bench_command_lookup_in_methods
    filename = fixture(:x86_64, "libhello.dylib")

    puts "Benchmarking: command() used in methods (segments, rpaths)"
    Benchmark.ips do |bm|
      bm.report("segments") do
        file = MachO.open(filename)
        file.segments
      end

      bm.report("rpaths") do
        file = MachO.open(filename)
        file.rpaths
      end

      bm.report("dylib_id") do
        file = MachO.open(filename)
        file.dylib_id
      end
    end
    puts
  end
end

if __FILE__ == $PROGRAM_NAME
  CommandLookupBenchmark.new.run
end
