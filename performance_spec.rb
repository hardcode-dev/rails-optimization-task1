require 'rspec'
require 'rspec-benchmark'
require_relative 'task-1.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'data 10_000' do
  it 'perform less 100 ms' do
    file_lines = File.read('data_large.txt').split("\n").first(10_000)
    expect { collect_stats(file_lines) }.to perform_under(100).ms.warmup(2).times.sample(10).times
  end
end

describe 'data 20_000' do
  it 'perform less 200 ms' do
    file_lines = File.read('data_large.txt').split("\n").first(20_000)
    expect { collect_stats(file_lines) }.to perform_under(200).ms.warmup(2).times.sample(10).times
  end
end

describe 'data 40_000' do
  it 'perform less 400 ms' do
    file_lines = File.read('data_large.txt').split("\n").first(40_000)
    expect { collect_stats(file_lines) }.to perform_under(400).ms.warmup(2).times.sample(10).times
  end
end
