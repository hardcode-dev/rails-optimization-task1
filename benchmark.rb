require 'benchmark'
require 'benchmark/ips'

require_relative 'task-1'

LINE_COUNT_FOR_IPS = 8

Benchmark.bm do |x|
  counters = [1, 2, 4, 8, 160, 3000]

  counters.each do |counter|
    `head -n #{counter * 1000} data_large.txt > data.txt`

    x.report { work }
  end
end

Benchmark.ips do |x|
  x.config(
    stats: :bootstrap,
    confidence: 95
  )
  `head -n #{LINE_COUNT_FOR_IPS * 1000} data_large.txt > data.txt`

  x.report("work(#{LINE_COUNT_FOR_IPS * 1000} lines)") { work }
end

