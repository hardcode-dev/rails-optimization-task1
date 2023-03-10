require 'benchmark'
require_relative 'task-1'

time = Benchmark.realtime do
  work(file_lines: File.read('data_large.txt').split("\n"))
end

puts "Finish in #{time.round(2)}"
