# frozen_string_literal: true

require 'rspec-benchmark'
require_relative 'task_1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe 'program' do
    let(:data) { 'data_small.txt' }
    it 'works under 250 ms' do
      expect { work(data) }.to perform_under(250).ms.warmup(2).times.sample(10).times
    end
  end
end
