require 'benchmark'
require_relative 'task-1.rb'

Benchmark.bm do |x|
  x.report('work') { work('data_small.txt') }

end
