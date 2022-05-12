# frozen_string_literal: true

require 'benchmark/ips'
require_relative '../task-1'
require_relative '../task_1'

Benchmark.ips do |x|
  x.config(stats: :bootstrap, confidence: 95)

  x.report('slow') { work }
  x.report('fast') { work_new }
  x.compare!
end
