require "benchmark"
require_relative 'work_method.rb'

ROWS_COUNT = 10000

time = Benchmark.realtime do
  work("data#{ROWS_COUNT}.txt")
end

puts "finish in #{time.round(2)}"
