require_relative 'task-1.rb'
# require 'rspec'
require 'rspec-benchmark'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

# RSpec.describe "Performance testing" do
#   include RSpec::Benchmark::Matchers
# end

describe 'Performance' do
  describe 'work' do
    it 'works under 120 ms' do
      expect {
        work('data5000.txt', disable_gc: true)
      }.to perform_under(45).ms.warmup(2).times.sample(10).times
    end
  end
end
