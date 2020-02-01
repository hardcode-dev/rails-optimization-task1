require 'benchmark'
require_relative 'task-1'

time = Benchmark.realtime do
  work('data_small.txt')
end

puts "Finish in #{time.round(2)}"