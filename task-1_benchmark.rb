require 'benchmark'
require './task-1'

include Benchmark

Benchmark.bm do |x|
  [11, 51, 100, 501, 1_000, 5_000, 10_000, 20_001, 30_000, 40_000, 50_000].each do |line_count|
    x.report("line_count = #{line_count}") { work_with_line_count(line_count) }
  end
end
