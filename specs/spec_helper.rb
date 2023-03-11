require 'rspec-benchmark'
require 'rspec'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end