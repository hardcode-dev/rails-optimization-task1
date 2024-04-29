#!/usr/bin/env ruby

# require 'benchmark'

# Benchmark.bm do |x|
#   x.report { work('sample100.txt') }
#   x.report { work('sample1000.txt') }
#   x.report { work('sample10000.txt') }
# end

require_relative 'task-1.rb'
require 'stackprof'
require 'json'

GC.disable

profile = StackProf.run(mode: :wall, raw: true) do
  work('data_small.txt')
end

File.write('stackprof_reports/stackprof.json', JSON.generate(profile))
