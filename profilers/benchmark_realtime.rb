require 'benchmark'
include Benchmark 

require './task1'

Benchmark.benchmark(CAPTION, 7, FORMAT) do |x|
  x.report('100 lines') { work('spec/fixtures/100_lines.txt') }
  x.report('1k lines') { work('spec/fixtures/1000_lines.txt') }
  x.report('10k lines') { work('spec/fixtures/10000_lines.txt') }
end
