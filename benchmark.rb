require 'benchmark'
require 'benchmark/ips'

require_relative 'task-1'

# file_with_data = 'data_1k.txt'

# puts "Start: #{file_with_data}"

# time = Benchmark.realtime do
#   #GC.disable
#   work(file_with_data)
# end

# puts "Finish in #{time.round(3)}"


Benchmark.bm do |x|
  counters = [1, 2, 4, 8, 16, 200]

  counters.each do |counter|
    `head -n #{counter * 1000} data_large.txt > data.txt`

    x.report { work }
  end
end

LINE_COUNT_FOR_IPS = 8

Benchmark.ips do |x|
  x.config(
    stats: :bootstrap,
    confidence: 95
  )
  `head -n #{LINE_COUNT_FOR_IPS * 1000} data_large.txt > data.txt`

  x.report("work(#{LINE_COUNT_FOR_IPS * 1000} lines)") { work }
end

# Benchmark.ips do |x|
#   x.config(
#     stats: :bootstrap,
#     confidence: 95
#   )

#   counters = [1, 2, 4, 8, 16]

#   counters.each do |counter|
#     `head -n #{counter * 1000} data_large.txt > data.txt`

#     x.report("work(file_with_data)") { work }
#   end  
# end

