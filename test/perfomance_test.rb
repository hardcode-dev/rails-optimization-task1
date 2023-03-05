require 'rspec'
require 'rspec-benchmark'
require_relative '../task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'performance' do
  describe 'task-1' do
    it 'work n ms' do
      expect {
        work("data/data-8000-lines.txt")
      }.to perform_under(250).ms.warmup(2).times.sample(5).times
    end
  end
end
