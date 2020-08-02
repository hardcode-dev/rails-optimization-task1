# frozen_string_literal: true

require 'benchmark/ips'
require_relative '../task-1'

test_path_20k = 'files/data-20k'
test_path_100k = 'files/data-100k'
test_path_300k = 'files/data-300k'

Benchmark.ips do |x|
  x.report('20k') { work(test_path_20k) }
  x.report('100k') { work(test_path_100k) }
  x.report('300k') { work(test_path_300k) }
end
