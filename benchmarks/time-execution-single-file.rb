require_relative '../lib/task-1'
require 'benchmark'

time = Benchmark.measure do
  work('files/data_16000.txt')
end

puts time
