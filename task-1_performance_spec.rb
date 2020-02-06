require 'rspec-benchmark'
require_relative 'task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe 'Lenear work' do
    it 'works with 100 strings under 1 ms' do
      expect { work('data100.txt') }.to perform_under(1).ms
    end

    it 'works with 500 strings under 1 ms' do
      expect { work('data500.txt') }.to perform_under(1).ms
    end

    it 'works with 1000 strings under 1 ms' do
      expect { work('data1000.txt') }.to perform_under(1).ms
    end

    it 'works with 5000 strings under 1 ms' do
      expect { work('data5000.txt') }.to perform_under(1).ms
    end

    it 'works with 10000 strings under 1 ms' do
      expect { work('data10000.txt') }.to perform_under(1).ms
    end
  end
end