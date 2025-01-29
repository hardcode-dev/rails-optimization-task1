require 'rspec-benchmark'
require_relative '../task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Perfomance' do
  describe 'work' do
    it 'works under 45 ms for 10_000 lines' do
      expect {
        work(filename: 'files/data_10_000.txt')
      }.to perform_under(45).ms.warmup(2).times.sample(10).times
    end

    it 'works under 550 ms for 100_000 lines' do
      expect {
        work(filename: 'files/data_100_000.txt')
      }.to perform_under(550).ms.warmup(2).times.sample(10).times
    end
  end
end