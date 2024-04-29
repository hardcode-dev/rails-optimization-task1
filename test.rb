require_relative 'task-1.rb'

require 'benchmark'

Benchmark.bm do |x|
  x.report { work('sample100.txt') }
  x.report { work('sample1000.txt') }
  x.report { work('sample10000.txt') }
  x.report { work('sample100000.txt') }
end
