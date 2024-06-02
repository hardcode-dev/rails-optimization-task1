require_relative 'task-1'
require 'benchmark'

puts "Start work"
# GC.disable
time = Benchmark.realtime do
  work('data_large.txt')
end

puts "Finish in #{time.round(2)}"
