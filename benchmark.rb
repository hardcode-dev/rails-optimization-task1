require_relative 'task-1'
require 'benchmark'

require 'benchmark/ips'

Benchmark.ips do |x|
  x.config(stats: :bootstrap, confidence: 95)

  x.report("ips") do
    work('samples/1000.txt')
  end
end

# puts "Start"
#
# time = Benchmark.realtime do
#   50.times{ work('samples/1000.txt') }
# end
#
# puts "Finish in #{(time/50).round(10)}"


