require 'benchmark/ips'
require 'benchmark'

require_relative '../work.rb'

Benchmark.ips do |x|
  # The default is :stats => :sd, which doesn't have a configurable confidence
  # confidence is 95% by default, so it can be omitted
  x.config(
    stats: :bootstrap,
    confidence: 95,
  )

  x.report('Work benchmark') do
    work(filename: 'data_test.txt', disable_gc: false)
  end
end

# time = Benchmark.realtime do
#   work(filename: 'data_test.txt', disable_gc: false)
# end
#
# puts "Finish in #{time.round(2)}"
