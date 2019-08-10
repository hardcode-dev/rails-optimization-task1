require 'benchmark'
require './01-task-1.rb'
require './02-task-1-refactored.rb'

GC.disable
refactored = Refactored.new

time = Benchmark.realtime do
  File.write('result.json', '')
  refactored.work('data_bench.txt')
end

puts "Finish in #{time.round(4) * 1000} ms"