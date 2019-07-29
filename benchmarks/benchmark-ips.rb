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
# iter-2
#      12.967k (± 5.1%) i/s -     64.680k in   5.078607s
#                    with 95.0% confidence
# 1.162  (±17.7%) i/s -      6.000  in   5.410667s
#                    with 95.0% confidence
