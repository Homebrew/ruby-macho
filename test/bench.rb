require "helpers"
require "benchmark/ips"

class RubyMachOBenchmark
  include Helpers

  def run
    unless installed?("otool") && installed?("install_name_tool")
      puts "otool and install_name_tool are required to run benchmarks."
      return
    end

    bench_get_id
    bench_get_dylib
    bench_set_id
    bench_set_dylib
    bench_add_rpath
    bench_delete_rpath
    bench_change_rpath

    bench_fat_get_id
    bench_fat_get_dylib
    bench_fat_set_id
    bench_fat_set_dylib
    bench_fat_add_rpath
    bench_fat_delete_rpath
    bench_fat_change_rpath
  end

  def bench_get_id
    filename = fixture(:x86_64, "libhello.dylib")

    Benchmark.ips do |bm|
      bm.report("otool_get_id") do
        libs = `otool -L #{filename}`.split("\n")
        libs.shift
        libs.shift[OTOOL_RX, 1]
      end

      bm.report("ruby_get_id") do
        MachO.open(filename).dylib_id
      end

      bm.compare!
    end
  end

  def bench_get_dylib
    filename = fixture(:x86_64, "libhello.dylib")

    Benchmark.ips do |bm|
      bm.report("otool_get_dylib") do
        libs = `otool -L #{filename}`.split("\n")
        libs.shift(2)
        libs.map! { |lib| lib[OTOOL_RX, 1] }.compact!
      end

      bm.report("ruby_get_dylib") do
        MachO::Tools.dylibs(filename)
      end

      bm.compare!
    end
  end

  def bench_set_id
    filename = fixture(:x86_64, "libhello.dylib")
    benchfile = "#{filename}.bench"
    FileUtils.cp(filename, benchfile)
    i = 0

    Benchmark.ips do |bm|
      bm.report("int_set_id") do
        `install_name_tool -id #{i += 1} #{benchfile}`
      end

      i = 0

      bm.report("ruby_set_id") do
        MachO::Tools.change_dylib_id(benchfile, (i += 1).to_s)
      end

      bm.compare!
    end
  ensure
    delete_if_exists(benchfile)
  end

  def bench_set_dylib
    filename = fixture(:x86_64, "libhello.dylib")
    benchfile = "#{filename}.bench"
    FileUtils.cp(filename, benchfile)
    i = 0

    Benchmark.ips do |bm|
      MachO::Tools.change_install_name(benchfile, "/usr/lib/libSystem.B.dylib", "0")

      bm.report("int_set_dylib") do
        `install_name_tool -change #{i} #{i += 1} #{benchfile}`
      end

      MachO::Tools.change_install_name(benchfile, i.to_s, "0")
      i = 0

      bm.report("ruby_set_dylib") do
        MachO::Tools.change_install_name(benchfile, i.to_s, (i += 1).to_s)
      end

      bm.compare!
    end
  ensure
    delete_if_exists(benchfile)
  end

  def bench_add_rpath
    filename = fixture(:x86_64, "libhello.dylib")
    benchfile = "#{filename}.bench"
    i = 0

    Benchmark.ips do |bm|
      bm.report("int_add_rpath") do
        FileUtils.cp(filename, benchfile)
        `install_name_tool -add_rpath #{i += 1} #{benchfile}`
        FileUtils.rm(benchfile)
      end

      bm.report("ruby_add_rpath") do
        FileUtils.cp(filename, benchfile)
        MachO::Tools.add_rpath(benchfile, (i += 1).to_s)
        FileUtils.rm(benchfile)
      end

      bm.compare!
    end
  ensure
    delete_if_exists(benchfile)
  end

  def bench_delete_rpath
    filename = fixture(:x86_64, "hello.bin")
    benchfile = "#{filename}.bench"
    rpath = MachO.open(filename).rpaths.first

    Benchmark.ips do |bm|
      bm.report("int_del_rpath") do
        FileUtils.cp(filename, benchfile)
        `install_name_tool -delete_rpath #{rpath} #{benchfile}`
        FileUtils.rm(benchfile)
      end

      bm.report("ruby_del_rpath") do
        FileUtils.cp(filename, benchfile)
        MachO::Tools.delete_rpath(benchfile, rpath)
        FileUtils.rm(benchfile)
      end

      bm.compare!
    end
  ensure
    delete_if_exists(benchfile)
  end

  def bench_change_rpath
    filename = fixture(:x86_64, "hello.bin")
    benchfile = "#{filename}.bench"
    FileUtils.cp(filename, benchfile)
    rpath = MachO.open(filename).rpaths.first
    i = 0

    MachO::Tools.change_rpath(benchfile, rpath, i.to_s)

    Benchmark.ips do |bm|
      bm.report("int_change_rpath") do
        `install_name_tool -rpath #{i} #{i += 1} #{benchfile}`
      end

      bm.report("ruby_change_rpath") do
        MachO::Tools.change_rpath(benchfile, i.to_s, (i += 1).to_s)
      end

      bm.compare!
    end
  ensure
    delete_if_exists(benchfile)
  end

  def bench_fat_get_id
    filename = fixture([:i386, :x86_64], "libhello.dylib")

    Benchmark.ips do |bm|
      bm.report("otool_fat_get_id") do
        libs = `otool -L #{filename}`.split("\n")
        libs.shift
        libs.shift[OTOOL_RX, 1]
      end

      bm.report("ruby_fat_get_id") do
        MachO.open(filename).dylib_id
      end

      bm.compare!
    end
  end

  def bench_fat_get_dylib
    filename = fixture([:i386, :x86_64], "libhello.dylib")

    Benchmark.ips do |bm|
      bm.report("otool_fat_get_dylib") do
        libs = `otool -L #{filename}`.split("\n")
        libs.shift(2)
        libs.map! { |lib| lib[OTOOL_RX, 1] }.compact!
      end

      bm.report("ruby_fat_get_dylib") do
        MachO::Tools.dylibs(filename)
      end

      bm.compare!
    end
  end

  def bench_fat_set_id
    filename = fixture([:i386, :x86_64], "libhello.dylib")
    benchfile = "#{filename}.bench"
    FileUtils.cp(filename, benchfile)
    i = 0

    Benchmark.ips do |bm|
      bm.report("int_fat_set_id") do
        `install_name_tool -id #{i += 1} #{benchfile}`
      end

      i = 0

      bm.report("ruby_fat_set_id") do
        MachO::Tools.change_dylib_id(benchfile, (i += 1).to_s)
      end

      bm.compare!
    end
  ensure
    delete_if_exists(benchfile)
  end

  def bench_fat_set_dylib
    filename = fixture([:i386, :x86_64], "libhello.dylib")
    benchfile = "#{filename}.bench"
    FileUtils.cp(filename, benchfile)
    i = 0

    Benchmark.ips do |bm|
      MachO::Tools.change_install_name(benchfile, "/usr/lib/libSystem.B.dylib", "0")

      bm.report("int_fat_set_dylib") do
        `install_name_tool -change #{i} #{i += 1} #{benchfile}`
      end

      MachO::Tools.change_install_name(benchfile, i.to_s, "0")
      i = 0

      bm.report("ruby_fat_set_dylib") do
        MachO::Tools.change_install_name(benchfile, i.to_s, (i += 1).to_s)
      end

      bm.compare!
    end
  ensure
    delete_if_exists(benchfile)
  end

  def bench_fat_add_rpath
    filename = fixture([:i386, :x86_64], "libhello.dylib")
    benchfile = "#{filename}.bench"
    i = 0

    Benchmark.ips do |bm|
      bm.report("int_fat_add_rpath") do
        FileUtils.cp(filename, benchfile)
        `install_name_tool -add_rpath #{i += 1} #{benchfile}`
        FileUtils.rm(benchfile)
      end

      bm.report("ruby_fat_add_rpath") do
        FileUtils.cp(filename, benchfile)
        MachO::Tools.add_rpath(benchfile, (i += 1).to_s)
        FileUtils.rm(benchfile)
      end

      bm.compare!
    end
  ensure
    delete_if_exists(benchfile)
  end

  def bench_fat_delete_rpath
    filename = fixture([:i386, :x86_64], "hello.bin")
    benchfile = "#{filename}.bench"
    rpath = MachO.open(filename).rpaths.first

    Benchmark.ips do |bm|
      bm.report("int_fat_del_rpath") do
        FileUtils.cp(filename, benchfile)
        `install_name_tool -delete_rpath #{rpath} #{benchfile}`
        FileUtils.rm(benchfile)
      end

      bm.report("ruby_fat_del_rpath") do
        FileUtils.cp(filename, benchfile)
        MachO::Tools.delete_rpath(benchfile, rpath)
        FileUtils.rm(benchfile)
      end

      bm.compare!
    end
  ensure
    delete_if_exists(benchfile)
  end

  def bench_fat_change_rpath
    filename = fixture([:i386, :x86_64], "hello.bin")
    benchfile = "#{filename}.bench"
    FileUtils.cp(filename, benchfile)
    rpath = MachO.open(filename).rpaths.first
    i = 0

    MachO::Tools.change_rpath(benchfile, rpath, i.to_s)

    Benchmark.ips do |bm|
      bm.report("int_fat_change_rpath") do
        `install_name_tool -rpath #{i} #{i += 1} #{benchfile}`
      end

      bm.report("ruby_fat_change_rpath") do
        MachO::Tools.change_rpath(benchfile, i.to_s, (i += 1).to_s)
      end

      bm.compare!
    end
  ensure
    delete_if_exists(benchfile)
  end
end
