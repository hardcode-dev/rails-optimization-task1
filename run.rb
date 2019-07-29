require_relative 'work_method'
require 'benchmark/ips'

Benchmark.ips do |x|
  # The default is :stats => :sd, which doesn't have a configurable confidence
  # confidence is 95% by default, so it can be omitted
  x.config(
    stats: :bootstrap,
    confidence: 95,
    )

  x.report("work") do
    work('data_large.txt')
  end
end