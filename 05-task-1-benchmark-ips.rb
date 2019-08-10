require 'benchmark/ips'
require './01-task-1.rb'
require './02-task-1-refactored.rb'

GC.disable
refactored = Refactored.new

Benchmark.ips do |x|
  x.config(stats: :bootstrap, confidence: 99)

  x.report("original method work") do
    File.write('result.json', '')
    work('data_bench.txt')
  end

  x.report("refactored method work") do
    File.write('result.json', '')
    refactored.work('data_bench.txt')
  end

  x.compare!
end
