require 'benchmark'
require_relative 'task-1'

time = Benchmark.realtime do
  work(disable_gc: false)
end

puts "Finish in #{time.round(2)}"
