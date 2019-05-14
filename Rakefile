# frozen_string_literal: true

$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/lib"
require "rake/testtask"
require_relative "test/bench"

Rake::TestTask.new do |t|
  t.libs << "test"
end

desc "Run tests"
task :default => :test

desc "Run benchmarks"
task :bench do
  RubyMachOBenchmark.new.run
end
