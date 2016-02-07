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
		bench_get_dylibs
		bench_set_id
		bench_set_dylibs
	end

	def bench_get_id
		Benchmark.ips do |bm|
			bm.report("otool_get_id") do
				libs = `otool -L #{TEST_DYLIB}`.split("\n")
				libs.shift
				libs.shift[OTOOL_RX, 1]
			end

			bm.report("ruby_get_id") do
				MachO.open(TEST_DYLIB).dylib_id
			end
		end
	end

	def bench_get_dylibs
		Benchmark.ips do |bm|
			bm.report("otool_get_dylib") do
				libs = `otool -L #{TEST_DYLIB}`.split("\n")
				libs.shift(2)
				libs.map! { |lib| lib[OTOOL_RX, 1] }.compact!
			end

			bm.report("ruby_get_dylib") do
				MachO::Tools.dylibs(TEST_DYLIB)
			end
		end
	end

	def bench_set_id
		i = 0
		benchfile = "#{TEST_DYLIB}.bench"
		FileUtils.cp("#{TEST_DYLIB}", benchfile)

		Benchmark.ips do |bm|
			bm.report("int_set_id") do
				`install_name_tool -id #{i += 1} #{benchfile}`
			end

			i = 0

			bm.report("ruby_set_id") do
				MachO::Tools.change_dylib_id(benchfile, "#{i += 1}")
			end
		end
	ensure
		delete_if_exists(benchfile)
	end

	def bench_set_dylibs
		i = 0
		benchfile = "#{TEST_DYLIB}.bench"
		FileUtils.cp("#{TEST_DYLIB}", benchfile)

		Benchmark.ips do |bm|
			MachO::Tools.change_install_name(benchfile, "/usr/lib/libSystem.B.dylib", "0")

			bm.report("int_set_dylib") do
				`install_name_tool -change #{i} #{i += 1} #{benchfile}`
			end

			MachO::Tools.change_install_name(benchfile, "#{i}", "0")
			i = 0

			bm.report("ruby_set_dylib") do
				MachO::Tools.change_install_name(benchfile, "#{i}", "#{i += 1}")
			end
		end
	ensure
		delete_if_exists(benchfile)
	end
end
