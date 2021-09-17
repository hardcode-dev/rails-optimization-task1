require 'rspec-benchmark'
require_relative 'task-1.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Perfomance' do
  describe 'work' do
    it 'works under 200ms for 10000 lines' do
      expect { work('files/data_10000.txt') }.to perform_under(250).ms.warmup(2).times.sample(10).times
    end

    it 'works under 100ms for 10000 lines' do
      expect { work('files/data_10000.txt') }.to perform_under(100).ms.warmup(2).times.sample(10).times
    end

    it 'works under 50ms for 10000 lines' do
      expect { work('files/data_10000.txt') }.to perform_under(50).ms.warmup(2).times.sample(10).times
    end
  end
end
