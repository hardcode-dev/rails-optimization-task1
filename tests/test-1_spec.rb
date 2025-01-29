require 'rspec-benchmark'
require_relative '../task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  it '80_000 works under 0.2s' do
    expect do
      work('data/data80000.txt')
    end.to perform_under(200).ms.warmup(2).times.sample(5).times
  end

  it 'has linear performance' do
    expect do |n, _i|
      work("data/data#{n}000.txt")
    end.to perform_linear.in_range([20, 80, 160, 320])
  end
end
