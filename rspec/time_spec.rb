require 'rspec-benchmark'
require_relative '../task-1.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe 'work' do
    let(:filename) { 'rspec/test_data/data100000.txt' }
    it 'works under 0.5 s' do
      expect {
        work(filename)
      }.to perform_under(500).ms.warmup(2).times.sample(10).times
    end
  end
end
