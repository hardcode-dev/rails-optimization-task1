require 'benchmark/ips'

require './task1'

Benchmark.ips do |x|
  # x.stats = :bootstrap
  # x.confidence = 95
  x.time = 5
  x.warmup = 2

  x.report('100 lines') { work('spec/fixtures/100_lines.txt') }
  x.report('1k lines') { work('spec/fixtures/1_000_lines.txt') }
  x.report('10k lines') { work('spec/fixtures/10_000_lines.txt') }

  x.compare!
end
