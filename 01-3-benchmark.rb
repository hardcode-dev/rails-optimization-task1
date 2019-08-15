require 'benchmark/ips'
require_relative 'codes/report'

report = Report.new(:benchmark_3)

res = Benchmark.ips do |x|
  # The default is :stats => :sd, which doesn't have a configurable confidence
  # confidence is 95% by default, so it can be omitted
  x.config(
      stats: :bootstrap,
      confidence: 95,
      )

  x.report("task-1") do
    report.run
  end
end

report.save(res.entries.first.body)
