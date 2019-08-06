require 'minitest/benchmark'
require 'benchmark/ips'
require_relative '../task-1'

Benchmark.ips do |x|
  x.report('work 64000') do
      work('data/data_large.txt')
  end
end