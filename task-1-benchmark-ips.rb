require 'benchmark/ips'
require './task-1.rb'
require './task-1-refactored.rb'

GC.disable
refactored = Refactored.new

Benchmark.ips do |x|
  x.config(stats: :bootstrap, confidence: 99)

  x.report("original method work") do
    work('data_bench.txt')
  end

  x.report("refactored method work") do
    refactored.work('data_bench.txt')
  end

  x.compare!
end
