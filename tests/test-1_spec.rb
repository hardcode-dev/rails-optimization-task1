require 'rspec-benchmark'
require_relative '../task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  it '20_000 works under 0.4 ms' do
    expect do
      work('data/data20000.txt')
    end.to perform_under(400).ms.warmup(2).times.sample(5).times
  end
end
