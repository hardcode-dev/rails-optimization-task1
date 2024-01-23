require 'rspec-benchmark'
require './task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe '#work' do
    let(:line_count) { 20_001 }
    let(:expected_time) { 4 }

    it 'works under or equal expected time' do
      expect { work_with_line_count(line_count) }.to perform_under(expected_time).sec.warmup(2).times.sample(4).times
    end
  end
end
