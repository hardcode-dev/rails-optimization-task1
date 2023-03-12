require 'rspec-benchmark'
require_relative 'task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe 'task_1' do
    let(:file) { 'data/data10000.txt' }
    it 'works under 40 ms' do
      expect {
        work(file)
      }.to perform_under(40).ms.warmup(2).times.sample(10).times
    end

    let(:measurement_time_seconds) { 1 }
    let(:warmup_seconds) { 0.2 }
    it 'works faster than 20 ips' do
      expect {
        work(file)
      }.to perform_at_least(20).within(measurement_time_seconds).warmup(warmup_seconds).ips
    end

    it 'performs linear' do
      expect { work('data/data10000.txt') }.to perform_linear
    end
  end
end