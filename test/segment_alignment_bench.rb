# frozen_string_literal: true

require_relative "helpers"
require "benchmark/ips"

class SegmentAlignmentBenchmark
  include Helpers

  def run
    puts "=" * 80
    puts "Baseline Benchmarks for segment_alignment (Recommendation #5)"
    puts "=" * 80
    puts

    bench_single_call
    bench_repeated_calls
    bench_fat_file_construction_simulation
  end

  def bench_single_call
    filename = fixture(:x86_64, "libhello.dylib")

    puts "Benchmarking: segment_alignment (single call)"
    Benchmark.ips do |bm|
      bm.report("segment_alignment") do
        file = MachO.open(filename)
        file.segment_alignment
      end
    end
    puts
  end

  def bench_repeated_calls
    filename = fixture(:x86_64, "libhello.dylib")
    file = MachO.open(filename)

    puts "Benchmarking: segment_alignment (10 repeated calls on same instance)"
    Benchmark.ips do |bm|
      bm.report("segment_alignment x10") do
        10.times { file.segment_alignment }
      end
    end
    puts
  end

  def bench_fat_file_construction_simulation
    # Simulate what happens in FatFile.new_from_machos
    # where segment_alignment is called multiple times per macho
    filenames = [
      fixture(:x86_64, "libhello.dylib"),
      fixture(:x86_64, "hello.bin"),
    ]
    files = filenames.map { |f| MachO.open(f) }

    puts "Benchmarking: segment_alignment in FatFile construction scenario"
    Benchmark.ips do |bm|
      bm.report("2 files, 5 calls each") do
        files.each do |file|
          5.times { file.segment_alignment }
        end
      end
    end
    puts
  end
end

if __FILE__ == $PROGRAM_NAME
  SegmentAlignmentBenchmark.new.run
end
