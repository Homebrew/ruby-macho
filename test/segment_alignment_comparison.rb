# frozen_string_literal: true

require_relative "helpers"
require "benchmark/ips"

class SegmentAlignmentComparison
  include Helpers

  def run
    puts "=" * 80
    puts "segment_alignment Memoization - Before vs After Comparison"
    puts "=" * 80
    puts
    puts "BEFORE: segment_alignment computed every time"
    puts "AFTER:  segment_alignment memoized (computed once, cached thereafter)"
    puts
    puts "=" * 80
    puts

    bench_repeated_calls_comparison
    bench_fat_file_scenario
  end

  def bench_repeated_calls_comparison
    filename = fixture(:x86_64, "libhello.dylib")
    file = MachO.open(filename)

    puts "Benchmarking: Repeated calls to segment_alignment on same instance"
    puts
    Benchmark.ips do |bm|
      # Simulate "before" by calling the private method directly
      bm.report("BEFORE: 10 calls (no memoization)") do
        10.times { file.send(:calculate_segment_alignment) }
      end

      # Actual memoized calls
      bm.report("AFTER:  10 calls (with memoization)") do
        10.times { file.segment_alignment }
      end

      bm.compare!
    end
    puts
  end

  def bench_fat_file_scenario
    # Simulate FatFile.new_from_machos scenario where segment_alignment
    # is called multiple times per macho during fat binary construction
    filenames = [
      fixture(:x86_64, "libhello.dylib"),
      fixture(:x86_64, "hello.bin"),
    ]
    files = filenames.map { |f| MachO.open(f) }

    puts "Benchmarking: FatFile construction scenario (2 files, 5 calls each)"
    puts
    Benchmark.ips do |bm|
      bm.report("BEFORE: 2 files × 5 calls (no memo)") do
        files.each do |file|
          5.times { file.send(:calculate_segment_alignment) }
        end
      end

      bm.report("AFTER:  2 files × 5 calls (with memo)") do
        files.each do |file|
          5.times { file.segment_alignment }
        end
      end

      bm.compare!
    end
    puts
  end
end

if __FILE__ == $PROGRAM_NAME
  SegmentAlignmentComparison.new.run
end
