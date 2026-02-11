# frozen_string_literal: true

require_relative "helpers"
require "benchmark/ips"

class StringOpsBenchmark
  include Helpers

  def run
    puts "=" * 80
    puts "Baseline Benchmarks for Binary String Operations (Recommendation #3)"
    puts "=" * 80
    puts

    bench_delete_command
    bench_replace_command
    bench_add_rpath
    bench_delete_rpath
    bench_multiple_operations
  end

  def bench_delete_command
    filename = fixture(:x86_64, "hello.bin")

    puts "Benchmarking: delete_command (single operation)"
    Benchmark.ips do |bm|
      bm.report("delete_command") do
        file = MachO.open(filename)
        lc = file.command(:LC_RPATH).first
        file.delete_command(lc) if lc
      end
    end
    puts
  end

  def bench_replace_command
    filename = fixture(:x86_64, "libhello.dylib")

    puts "Benchmarking: replace_command (dylib_id)"
    Benchmark.ips do |bm|
      bm.report("replace_command") do
        file = MachO.open(filename)
        file.change_dylib_id("new_id_#{rand(1000)}")
      end
    end
    puts
  end

  def bench_add_rpath
    filename = fixture(:x86_64, "libhello.dylib")

    puts "Benchmarking: add_command (add_rpath)"
    Benchmark.ips do |bm|
      bm.report("add_rpath") do
        file = MachO.open(filename)
        file.add_rpath("/test/path/#{rand(1000)}")
      end
    end
    puts
  end

  def bench_delete_rpath
    filename = fixture(:x86_64, "hello.bin")

    puts "Benchmarking: delete_command (delete_rpath)"
    Benchmark.ips do |bm|
      bm.report("delete_rpath") do
        file = MachO.open(filename)
        rpath = file.rpaths.first
        file.delete_rpath(rpath) if rpath
      end
    end
    puts
  end

  def bench_multiple_operations
    filename = fixture(:x86_64, "hello.bin")

    puts "Benchmarking: multiple operations on same file"
    Benchmark.ips do |bm|
      bm.report("add + delete rpath (2 ops)") do
        file = MachO.open(filename)
        file.add_rpath("/tmp/test1")
        file.delete_rpath("/tmp/test1")
      end

      bm.report("add 3 rpaths") do
        file = MachO.open(filename)
        file.add_rpath("/tmp/test1")
        file.add_rpath("/tmp/test2")
        file.add_rpath("/tmp/test3")
      end
    end
    puts
  end
end

if __FILE__ == $PROGRAM_NAME
  StringOpsBenchmark.new.run
end
