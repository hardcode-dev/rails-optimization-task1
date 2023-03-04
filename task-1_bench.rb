# frozen_string_literal: true

require 'benchmark'

require_relative 'task-1'

Benchmark.bmbm do |x|
  x.report('1k')  { work('data_1k.txt') }
  x.report('2k')  { work('data_2k.txt') }
  x.report('4k')  { work('data_4k.txt') }
  x.report('8k')  { work('data_8k.txt') }
  x.report('16k') { work('data_16k.txt') }
  x.report('32k') { work('data_32k.txt') }
  x.report('64k') { work('data_64k.txt') }
  x.report('128k') { work('data_128k.txt') }
  x.report('256k') { work('data_256k.txt') }
  x.report('3250940') { work('data_large.txt') }
end
