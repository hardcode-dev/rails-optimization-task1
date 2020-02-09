require './work'
require 'benchmark'

include Benchmark

Benchmark.benchmark do |x|
  x.report("5000:") { work('test/data/data_5000.txt') }
end
