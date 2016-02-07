require "rake/testtask"
require_relative "test/bench"

Rake::TestTask.new do |t|
	t.libs << 'test'
end

desc "Run tests"
task :default => :test

desc "Run benchmarks"
task :bench do
	RubyMachOBenchmark.new.run
end
