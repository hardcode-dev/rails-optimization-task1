# frozen_string_literal: true

require 'benchmark/ips'
require_relative 'task-1'

Benchmark.ips do |x|
  x.config(stats: :bootstrap, confidance: 95)

  x.report('10_000') { work('data_10_000.txt') }
  x.report('20_000') { work('data_20_000.txt') }
  x.report('40_000') { work('data_40_000.txt') }
  x.compare!
end
