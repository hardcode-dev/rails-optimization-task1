require_relative 'task-1'.freeze
require 'benchmark'

def work_with_benchmark
  puts "На 100 строк: #{Benchmark.realtime { work('data100.txt') }}"
  puts "На 1000 строк: #{Benchmark.realtime { work('data1000.txt') }}"
  puts "На 10000 строк: #{Benchmark.realtime { work('data10000.txt') }}"
  puts "На 100000 строк: #{Benchmark.realtime { work('data100000.txt') }}"
  puts "На 1000000 строк: #{Benchmark.realtime { work('data1000000.txt') }}"
  puts "На data_large строк: #{Benchmark.realtime { work('data_large.txt') }}"
end

work_with_benchmark
