require 'benchmark'
require_relative 'task-1'

time = Benchmark.realtime do
  work(file_name: 'data_50_000.txt')
end

puts "Benchmark time #{time}"

