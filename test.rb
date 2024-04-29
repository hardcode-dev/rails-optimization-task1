#!/usr/bin/env ruby

# require 'benchmark'

# Benchmark.bm do |x|
#   x.report { work('sample100.txt') }
#   x.report { work('sample1000.txt') }
#   x.report { work('sample10000.txt') }
# end

require_relative 'task-1.rb'
require 'stackprof'

GC.disable

StackProf.run(mode: :wall, out: 'stackprof_reports/stackprof.dump', interval: 1000) do
  work('data_small.txt')
end
