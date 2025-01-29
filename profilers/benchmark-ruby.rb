# ruby profilers/benchmark-ruby.rb
require 'benchmark'
require_relative '../task-1.rb'

# GC.disable

puts "Start"


time = Benchmark.realtime do
  work('data_small.txt')
end

puts "small finished in #{time.round(2)}"

time = Benchmark.realtime do
  work('data_medium.txt')
end

puts "medium finished in #{time.round(2)}"

time = Benchmark.realtime do
  work('data_big.txt')
end

puts "big finished in #{time.round(2)}"

time = Benchmark.realtime do
  work('data_large.txt')
end

puts "large finished in #{time.round(2)}"