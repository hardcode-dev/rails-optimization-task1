require 'benchmark'
require_relative 'task-1'

measure = Benchmark.measure do
  work('data_large.txt', 'result.json', rows_count: ARGV.first.to_i, gc_disable: true)
end

p measure