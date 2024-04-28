# frozen_string_literal: true

require 'benchmark/ips'
require_relative '../../task-1'

file_name = './data1000.txt'

Benchmark.ips do |x|
  # The default is :stats => :sd, which doesn't have a configurable confidence
  # confidence is 95% by default, so it can be omitted
  x.config(
    stats: :bootstrap,
    confidence: 95
  )

  x.report('slow string concatenation') do
    work(file_name)
  end
end
