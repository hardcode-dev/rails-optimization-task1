

require 'rspec'
require 'rspec-benchmark'
require './task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe 'work' do
    it 'works in 30 seconds' do
      expect do
        work('data_large.txt')
      end.to perform_under(30).sec
    end
  end
end
