require 'rspec-benchmark'
require_relative 'task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe 'work' do
    # 100 lines under 0.32 milliseconds
    it 'should work under 0.32 milliseconds' do
      expect { work('data100.txt') }.to perform_under(0.32).ms.warmup(2).times.sample(10).times
    end

    # 1000 lines under 2.05 milliseconds
    it 'should work under 2.05 milliseconds' do
      expect { work('data1000.txt') }.to perform_under(2.05).ms.warmup(2).times.sample(10).times
    end

    # 10000 lines under 23 milliseconds
    it 'should work under 23 milliseconds' do
      expect { work('data10000.txt') }.to perform_under(23).ms.warmup(2).times.sample(10).times
    end

    let(:measurement_time_seconds) { 1 }
    let(:warmup_time_seconds) { 0.2 }
    it 'works faster than 3550 ips' do
      expect { work('data100.txt') }.to perform_at_least(3550).within(measurement_time_seconds).warmup(warmup_time_seconds).ips
    end

    let(:sizes) { [1000, 2000, 4000, 8000] }
    it 'performs linear' do
      expect { |n, _i| work("data#{n}.txt") }.to perform_linear.in_range(sizes)
    end
  end
end
