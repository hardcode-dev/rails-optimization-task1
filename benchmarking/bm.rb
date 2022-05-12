require 'benchmark'
require_relative '../task-1.rb'

Benchmark.bm do |bm|
  bm.report('1000') { work('./benchmarking/support/data_1k.txt') }
  bm.report('2000') { work('./benchmarking/support/data_2k.txt') }
  bm.report('4000') { work('./benchmarking/support/data_4k.txt') }
  bm.report('8000') { work('./benchmarking/support/data_8k.txt') }
  # bm.report('large') { work('../data_large.txt') }
end
