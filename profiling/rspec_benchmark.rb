# frozen_string_literal: true

require_relative '../task-1'
require 'rspec-benchmark'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  it 'works under 50 ms' do
    expect do
      work(input_filename: './data_large.txt')
    end.to perform_under(50).ms.warmup(2).times.sample(10).times
  end
end
