require 'rspec-benchmark'
require 'rspec'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

RSpec::Benchmark.configure do |config|
  config.samples = 10
end
