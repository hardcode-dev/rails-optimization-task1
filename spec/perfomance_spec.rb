require 'rspec-benchmark'
require_relative '../task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Perfomance' do
  describe 'work' do
    it 'works under 310 ms for 10_000 lines' do
      expect {
        work(filename: 'files/data_10_000.txt')
      }.to perform_under(310).ms.warmup(2).times.sample(10).times
    end

    it 'works under 5 sec for 50_000 lines' do
      expect {
        work(filename: 'files/data_50_000.txt')
      }.to perform_under(5000).ms.warmup(2).times.sample(10).times
    end
  end
end