require_relative 'task-1'
require 'benchmark'

puts "Start work"
# GC.disable
time = Benchmark.realtime do
  work
end

puts "Finish in #{time.round(2)}"
