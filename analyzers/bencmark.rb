# frozen_string_literal: true

require 'rspec-benchmark'
require_relative '../task_1'

DEMO_DATA_PATH = "#{__dir__}/demo_data/demo_data_100000.txt"

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'benchmark' do
  it 'check time for 100_000 lines' do
    expect { work(DEMO_DATA_PATH) }.to perform_under(92).ms.warmup(3).times.sample(5) # 100_000 lines < 0.92 sec
  end
end
