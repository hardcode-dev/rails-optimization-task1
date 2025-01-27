require 'rspec/core'
require 'rspec-benchmark'

require_relative 'task-1_with_argument.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  before do
    `head -n #{8000} data_large.txt > data_small.txt`
  end
  it 'works under 1 ms' do
    expect {
      work('data_small.txt')
    }.to perform_under(1000).ms.warmup(2).times.sample(10).times
  end

  let(:measurement_time_seconds) { 1 }
  let(:warmup_seconds) { 0.2 }
  it 'works faster than 1 ips' do
    expect {
      work('data_small.txt')
    }.to perform_at_least(1).within(measurement_time_seconds).warmup(warmup_seconds).ips
  end

  it 'works with data_large under 35sec' do
    expect {
      work('data_large.txt')
    }.to perform_under(35).sec.warmup(2).times.sample(10).times
  end
end
