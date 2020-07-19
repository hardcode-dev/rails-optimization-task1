# frozen_string_literal: true

require 'rspec-benchmark'
require_relative '../task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe '.work' do
    it 'works under 30 ms' do
      expect { work(file_name: 'tmp/data_10000.txt') }.to perform_under(2000).ms.warmup(2).times.sample(3).times
    end
  end
end
