require 'rspec'
require 'rspec-benchmark'

require_relative 'task-1.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'data_30_000.txt' do
  it 'performs less than 100 ms' do
    expect do
      work('data30_000.txt')
    end.to perform_under(100).ms.warmup(2).times.sample(10).times
  end
end
