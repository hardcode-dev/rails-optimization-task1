require 'benchmark'
require './task-1.rb'

GC.disable

time = Benchmark.realtime do
  File.write('result.json', '')
  work('data_bench.txt')
end

puts "Finish in #{time.round(4) * 1000} ms"