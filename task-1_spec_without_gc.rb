require 'rspec-benchmark'
require_relative 'task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Perfomance with disable garbage collection' do
  describe 'load simple data.txt file' do
    it 'should works under 1 ms' do
      expect { 
        work('fixtures/data.txt', disable_gc = true)
      }.to perform_under(1).ms.warmup(2).times.sample(10).times
    end
  end

  describe 'load large size file data_10000.txt with 1_000 lines and turn off garbage collection' do
    it 'should works under 5ms' do
      expect {
          work('fixtures/data_1000.txt', disable_gc = true)
        }.to perform_under(5).ms.warmup(2).times.sample(10).times
    end
  end

  describe 'load large size file data_10000.txt with 10_000 lines and turn off garbage collection' do
    it 'should works under 35ms' do
      expect {
          work('fixtures/data_10000.txt', disable_gc = true)
        }.to perform_under(35).ms.warmup(2).times.sample(10).times
    end
  end

  describe 'load large size file data_30000.txt with 20_000 lines and turn off garbage collection' do
    it 'should works under 0.1ms' do
      expect {
          work('fixtures/data_30000.txt', disable_gc = true)
        }.to perform_under(100).ms.warmup(2).times.sample(10).times
    end
  end
end