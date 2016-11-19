$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/lib"
$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/test"
require "rake/testtask"
require "bench"

Rake::TestTask.new do |t|
  t.libs << "test"
end

desc "Run tests"
task :default => :test

desc "Run benchmarks"
task :bench do
  RubyMachOBenchmark.new.run
end
