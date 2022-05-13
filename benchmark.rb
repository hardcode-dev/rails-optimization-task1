require 'benchmark'
require_relative './task-1'

time = Benchmark.realtime do |x|
  work(file_name: 'fixtures/data_large.txt', disable_gc: true)
end

puts time