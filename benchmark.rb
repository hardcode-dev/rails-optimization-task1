require 'benchmark'
require_relative 'task-1.rb'

puts "Start"

time = Benchmark.realtime do
  work('data5000.txt', disable_gc: false)
end

puts "Finish in #{time.round(2)}"
