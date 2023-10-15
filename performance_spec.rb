require 'rspec'
require 'rspec-benchmark'
require_relative 'task-1.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'with file with 50000 linex' do
  it 'performs for less than 250 ms' do
    expect do
      work('data_50_000.txt')
    end.to perform_under(250).ms.warmup(2).times.sample(10).times
  end
end