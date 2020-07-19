require 'benchmark'
require_relative 'task-1'

time = Benchmark.realtime do
  work(file_name: 'tmp/data_100000.txt')
end

puts "Finish in #{time.round(2)}"
