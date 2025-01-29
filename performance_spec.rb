require 'rspec-benchmark'

require_relative 'task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  before { `head -n 10000 data_large.txt > data.txt` }

  let(:measurement_time_seconds) { 2 }
  let(:warmup_seconds) { 1.2 }
  it 'works faster than  ips' do
    expect {
      work
    }.to perform_at_least(10).within(measurement_time_seconds).warmup(warmup_seconds).ips
  end

  it 'should perform under 100 ms' do
    expect { work }.to perform_under(100).ms
  end
end
