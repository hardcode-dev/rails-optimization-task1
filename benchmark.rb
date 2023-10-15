require 'benchmark'
require_relative 'task-1'

GC.disable
puts 'Started'
time = Benchmark.realtime do
  work('data10000.txt')
end
puts "Finished in #{time.round(2)}"

# Iteration 0: measurement without any changes = 0.72 seconds
# Iteration 1: measurement with changes for Array.select = 0.1 seconds
