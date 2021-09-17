require 'benchmark/ips'
require 'benchmark'
require_relative 'task-1.rb'

# Benchmark.ips do |x|
#   x.config(stats: :bootstrap, confidence: 95 )
#
#   x.report do
#     work('files/data_10000.txt', disable_gc: false)
#   end
# end


# time = Benchmark.realtime do
#   work('files/data_large.txt', disable_gc: false)
# end
#
# p "Finished in #{time.round(2)}"