require 'rspec-benchmark'
require_relative '../task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Perfomance' do
  describe 'task 1' do
    it 'works under 30 seconds' do
      expect {
        work('data_large.txt')
      }.to perform_under(30).sec.warmup(1).times.sample(3).times
    end
  end
end
