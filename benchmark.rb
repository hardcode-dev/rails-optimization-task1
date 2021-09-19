require 'benchmark'
require 'benchmark/ips'
# require_relative 'task'
require_relative 'task-1'

# Benchmark.ips do |x|
#   x.config(stats: :bootstrap, confidence: 95)

#   x.report do
#     work(filename: 'files/data_large.txt')
#   end
# end

time = Benchmark.realtime do
  work(filename: 'files/data_large.txt')
end

puts "\n"
puts "Benchmark realtime: #{time}"
puts "\n"

