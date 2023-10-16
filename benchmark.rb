require 'benchmark'
require_relative 'task-1'

GC.disable
puts 'Started'
time = Benchmark.realtime do
  work('data10000.txt')
end
puts "Finished in #{time.round(2)}"

# Iteration 0: measurement without any changes = 0.72 seconds
# Iteration 1: measurement with changes for Array.select = 0.1 seconds
# Iteration 2: measurement with changes for collect_stats_from_users = 0.1 seconds
# Iteration 3: measurement with changes for all? = 0.07 seconds
# Iteration 4: measurement with changes for split = 0.04 seconds
# Iteration 5: measurement with changes for Date = 0.02 seconds
