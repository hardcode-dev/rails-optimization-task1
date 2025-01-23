require 'rspec-benchmark'
require_relative "../lib/task-1"


RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end