require 'rspec-benchmark'
require_relative '../work_method'

RSpec::Benchmark.configure do |config|
  config.disable_gc = false
  config.samples = 3
end

RSpec.describe "Performance testing" do
  include RSpec::Benchmark::Matchers

  it { expect { work('data_large.txt', 128_000) }.to perform_under(860).ms }

  it { expect { |n, _i| work('data_large.txt', n) }.to perform_linear.in_range(1000, 64_000).ratio(2).threshold(0.90) }
end