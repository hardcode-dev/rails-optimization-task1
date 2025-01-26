# rspec task-1-assert-performance.rb

require 'rspec-benchmark'
require_relative 'task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe 'task-1#work' do
    it 'works with large data under 30 sec' do
      expect { work(file_name: "data_large.txt") }.to perform_under(30).sec
    end
  end
end
