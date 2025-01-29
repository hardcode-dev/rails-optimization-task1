# ruby profilers/benchmark-ips.rb
require 'benchmark/ips'
require_relative '../task-1.rb'

GC.disable

Benchmark.ips do |x|
  # The default is :stats => :sd, which doesn't have a configurable confidence
  # confidence is 95% by default, so it can be omitted
  x.config(
    stats: :bootstrap,
    confidence: 95,
  )

  x.report("work for small file") do
    work('data_small.txt')
  end

  x.report("work for medium file") do
    work('data_medium.txt')
  end
end