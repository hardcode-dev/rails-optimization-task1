require 'benchmark'
require 'benchmark/ips'
require_relative 'task-1_with_argument.rb'

COUNTERS = [1, 2, 4, 8, 16, 32, 64, 128, 256]

COUNTERS.each do |counter|
  time = Benchmark.realtime do
    `head -n #{counter*1000} data_large.txt > data_small.txt`
    work('data_small.txt')
  end
  puts "Finish in #{time.round(2)}"
end

# initial

# 1000  -  Finish in 0.03
# 2000  -  Finish in 0.13
# 4000  -  Finish in 0.31
# 8000  -  Finish in 0.97
# 16000 -  Finish in 3.98
# 32000 -  Finish in 22.26


Benchmark.ips do |x|
  x.config(
    stats: :bootstrap,
    confidence: 95,
  )

  x.report("work") do
    `head -n #{128000} data_large.txt > data_small.txt`
    work('data_small.txt')
  end
end

# initial

# work      0.236 (± 1.4%) i/s

time = Benchmark.realtime do
  work('data_large.txt')
end
puts "Finish in #{time.round(2)}"
