# gem install kalibera
require 'benchmark/ips'
require_relative '../task-1.rb'

ROWS = 100_000
COLS = 10
REPS = 1000

GC.disable

Benchmark.ips do |x|
  # The default is :stats => :sd, which doesn't have a configurable confidence
  # confidence is 95% by default, so it can be omitted
  x.config(
    stats: :bootstrap,
    confidence: 95,
  )

  x.report("data_1_000") do
    x.report('1_000') { work('data_1_000.txt', gc) }
  end
end
