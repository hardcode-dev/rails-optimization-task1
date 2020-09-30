require 'benchmark'
require_relative 'task-1'

time = Benchmark.realtime do
  work
end

puts "Finish in #{time.round(2)}"
