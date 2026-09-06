# frozen_string_literal: true

$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/lib"

require "bundler/gem_tasks"
require "rake/testtask"
require "rubocop/rake_task"
require "rubygems/package"
require "rubygems/spec_fetcher"
require "tmpdir"
require "yard"

require_relative "lib/macho"

task :default => :check
task :check => %i[rubocop test doc package_smoke]

desc "Verify that RELEASE_TAG matches the gem version"
task :verify_release_tag do
  release_tag = ENV.fetch("RELEASE_TAG") { abort "RELEASE_TAG is required" }
  expected_tag = "v#{MachO::VERSION}"
  abort "release tag #{release_tag} does not match #{expected_tag}" unless release_tag == expected_tag
end

desc "Verify that the gem version has not already been published"
task :verify_unpublished_version do
  dependency = Gem::Dependency.new("ruby-macho", "= #{MachO::VERSION}")
  matching_specs, errors = Gem::SpecFetcher.fetcher.spec_for_dependency(dependency)
  abort "could not verify published ruby-macho versions: #{errors.map(&:message).join("; ")}" unless errors.empty?
  abort "ruby-macho #{MachO::VERSION} is already published" unless matching_specs.empty?
end

desc "Build and smoke-test the packaged gem"
task :package_smoke => :build do
  gem_path = File.expand_path("pkg/ruby-macho-#{MachO::VERSION}.gem", __dir__)

  Dir.mktmpdir("ruby-macho-package") do |package_dir|
    Gem::Package.new(gem_path).extract_files(package_dir)
    package_lib = File.join(package_dir, "lib")
    env = {
      "BUNDLE_GEMFILE" => nil,
      "PACKAGE_LIB" => package_lib,
      "RUBYLIB" => package_lib,
      "RUBYOPT" => nil,
    }
    load_check = <<~'RUBY'
      require "macho"
      loaded_path = $LOADED_FEATURES.find { |path| path.end_with?("/macho.rb") }
      abort "macho was not loaded" unless loaded_path

      package_prefix = "#{File.realpath(ENV.fetch("PACKAGE_LIB"))}#{File::SEPARATOR}"
      abort "macho loaded from #{loaded_path}, not the packaged gem" unless File.realpath(loaded_path).start_with?(package_prefix)
    RUBY

    abort "packaged gem failed to load" unless system(env, Gem.ruby, "--disable-gems", "-e", load_check)
  end
end

RuboCop::RakeTask.new(:rubocop)

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
end

YARD::Rake::YardocTask.new(:doc) do |t|
  t.files = Dir["lib/**/*.rb"]
  t.options = ["--fail-on-warning"]
  t.stats_options = ["--list-undoc"]
end

desc "Run benchmarks"
task :bench do
  require_relative "test/bench"
  RubyMachOBenchmark.new.run
end
