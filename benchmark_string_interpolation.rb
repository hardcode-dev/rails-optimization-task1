require_relative 'work_method'
require 'benchmark/ips'

Benchmark.ips do |x|
  # The default is :stats => :sd, which doesn't have a configurable confidence
  # confidence is 95% by default, so it can be omitted
  x.config(
    stats: :bootstrap,
    confidence: 95,
    )

  a = 5
  b = 'test'

  x.report("string +") do
    1000.times { a.to_s + ' ' + b}
  end

  x.report("interpolate") do
    1000.times { "#{a} #{b}"}
  end

  x.compare!
end