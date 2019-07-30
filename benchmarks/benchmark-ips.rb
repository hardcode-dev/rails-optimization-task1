require 'benchmark/ips'

require_relative '../task-1'

Benchmark.ips do |x|
  # The default is :stats => :sd, which doesn't have a configurable confidence
  # confidence is 95% by default, so it can be omitted
  x.config(
      stats: :bootstrap,
      confidence: 95,
      )

  x.report("slow string concatenation") do
    work('../data.txt', disable_gc: false)
  end
end
# iter -1
#     2.995k (± 1.5%) i/s -     15.300k in   5.128179s
#                   with 95.0% confidence
#
#