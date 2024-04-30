# frozen_string_literal: true

require 'benchmark/ips'
require_relative 'task-1'

files = %w[data5000.txt data10000.txt data15000.txt data20000.txt]

Benchmark.ips do |x|
  # The default is :stats => :sd, which doesn't have a configurable confidence
  # confidence is 95% by default, so it can be omitted
  x.config(stats: :bootstrap, confidence: 95)

  files.each do |file_name|
    x.report(file_name) { work(file_name, disable_gc: true) }
  end
  x.compare!
end
