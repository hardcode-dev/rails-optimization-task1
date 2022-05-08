# frozen_string_literal: true

require 'benchmark/ips'
require_relative '../task_1'

FILENAME_SMALL = 'data.txt'
FILENAME_2_500 = 'data_2_500.txt'
FILENAME_5_000 = 'data_5_000.txt'
FILENAME_10_000 = 'data_10_000.txt'
FILENAME_LARGE = 'data_large.txt'

Benchmark.ips do |x|
  # The default is :stats => :sd, which doesn't have a configurable confidence
  # confidence is 95% by default, so it can be omitted
  x.config(stats: :bootstrap, confidence: 99)

  x.report(FILENAME_SMALL) { work("data/#{FILENAME_SMALL}", disable_gc: true) }
  x.report(FILENAME_2_500) { work("data/#{FILENAME_2_500}", disable_gc: true) }
  x.report(FILENAME_5_000) { work("data/#{FILENAME_5_000}", disable_gc: true) }
  x.compare!
end
