require 'rspec-benchmark'
require_relative '../task-1.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end
