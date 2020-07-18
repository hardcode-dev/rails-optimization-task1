require_relative '../lib/task-1'
require 'benchmark'

time = Benchmark.measure do
  work('data_16000.txt')
end

puts time
