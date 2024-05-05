require 'rspec-benchmark'

require_relative 'task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  # let(:file_with_data) { 'data_1k.txt' }
  # it 'works under 50 ms' do
  #   expect {
  #     work(file_with_data)
  #   }.to perform_under(50).ms.warmup(2).times.sample(10).times
  # end  

  before { `head -n 8000 data_large.txt > data.txt` }

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

  # it 'should be linear' do
  #   expect { |number, _|
  #     `head -n #{number * 1000} data_large.txt > data.txt`

  #     work
  #   }.to perform_linear.in_range(1, 10)
  # end
end
