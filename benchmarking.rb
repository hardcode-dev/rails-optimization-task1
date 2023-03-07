require 'benchmark'
require 'benchmark/ips'
require_relative 'task-1'

# 10_000 - 1s
# 20_000 - 3.65s
# 40_000 - 15.48s
# 80_000 - 69.78s

time = Benchmark.realtime do |x|
  work('data/data_40k.txt')
end
puts "Finish in #{time.round(2)}"

# Benchmark.ips do |x|
#   x.config(stats: :bootstrap, confidence: 95)
#   x.report('Working time') { work('data/data_large.txt') }
# end

# 10_000 - 0.02s
# 20_000 - 0.05s
# 40_000 - 0.1s
# 80_000 - 0.19s

# all data - 17.31s
# all data - 0.076  (± 0.0%) i/s -      1.000  in  13.222855s
