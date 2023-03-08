require 'rspec-benchmark'
require './task-1.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe 'task_1' do
    let(:file) { 'test_data/data10000.txt' }
    it 'works under 40 ms' do
      expect {
        work(filename: file)
      }.to perform_under(40).ms.warmup(2).times.sample(10).times
    end

    let(:measurement_time_seconds) { 1 }
    let(:warmup_seconds) { 0.2 }
    it 'works faster than 20 ips' do
      expect {
        work(filename: file)
      }.to perform_at_least(20).within(measurement_time_seconds).warmup(warmup_seconds).ips
    end
  end
end
