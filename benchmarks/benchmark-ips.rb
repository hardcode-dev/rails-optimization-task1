require 'benchmark/ips'

require_relative '../task-1'

Benchmark.ips do |x|
  # The default is :stats => :sd, which doesn't have a configurable confidence
  # confidence is 95% by default, so it can be omitted
  x.config(
      stats: :bootstrap,
      confidence: 95,
      )

  x.report("GC turn on") do
    work('../data.txt', disable_gc: false)
  end

  x.report("GC turn off") do
    work('../data.txt', disable_gc: true)
  end

  x.compare!
end
# iter -1
#     2.995k (± 1.5%) i/s -     15.300k in   5.128179s
#                   with 95.0% confidence
#
#
# iter-2 Test: GREEN GC: false
# 2.503k (± 1.3%) i/s -     12.496k in   5.007660s
#                    with 95.0% confidence
#
# iter-3 Test: GREEN GC: true
#    2.111k (± 3.4%) i/s -     10.441k in   5.035906s
#                    with 95.0% confidence