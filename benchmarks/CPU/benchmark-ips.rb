require 'benchmark/ips'

require_relative '../../task-1'

Benchmark.ips do |x|
  # The default is :stats => :sd, which doesn't have a configurable confidence
  # confidence is 95% by default, so it can be omitted
  x.config(
      stats: :bootstrap,
      confidence: 95,
      )

  x.report("work") do
    work('../data.txt')
  end
end
