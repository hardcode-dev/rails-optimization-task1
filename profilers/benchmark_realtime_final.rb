require 'benchmark'
include Benchmark 

require './task1'

Benchmark.benchmark(CAPTION, 7, FORMAT) do |x|
  x.report('large file') { work('spec/fixtures/data_large.txt') }
end
