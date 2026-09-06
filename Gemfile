# frozen_string_literal: true

source "https://rubygems.org"

group :test, :development do
  gem "benchmark-ips"
  # Keep YARD 0.9's legacy lexer on its IRB notifier path instead of its fallback shim on Ruby 4.
  gem "irb"
  gem "minitest"
  gem "rake"
  gem "rubocop"
  gem "simplecov", ">= 1.1", "< 2", :require => false
  gem "simplecov-cobertura", :require => false
  gem "yard", "~> 0.9"
end

group :development do
  gem "overcommit"
end
