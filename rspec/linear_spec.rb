require 'rspec-benchmark'
require_relative '../task-1.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe 'work' do
    let(:sizes) { [1000, 2000, 4000]}
    it 'performs linear' do
      expect { |n, _i| work("rspec/test_data/data#{n}.txt") }.to perform_linear.in_range(sizes)
    end
  end
end
