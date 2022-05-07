# frozen_string_literal: true

require 'rspec-benchmark'
require_relative '../task_1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Parse#work' do
  it 'test that all works' do
    Parser.new('specs/fixtures/data.txt')
    expected_result = File.read('specs/fixtures/expected_result.json')
    expect(File.read('result.json') ).to eq(expected_result)
  end
end

describe 'Performance' do
  it 'works under 50 ms for 16000 lines' do
    expect { Parser.new('specs/fixtures/data_16000.txt') }.to perform_under(50).ms.warmup(2).times.sample(5).times
  end

  def process_file(line_number)
    Parser.new("specs/fixtures/data_#{line_number}.txt")
  end

  # xit 'performs power' do
  #   expect { |n, _i| process_file(n) }.to perform_power.in_range([1000, 2000, 4000, 8000, 16_000])
  # end

  it 'performs linear' do
    expect { |n, _i| process_file(n) }.to perform_linear.in_range([1000, 2000, 4000, 8000, 16_000, 32_000, 64_000])
  end
end
