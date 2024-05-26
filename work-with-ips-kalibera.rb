require_relative 'task-1'
require 'benchmark/ips'

puts 'Start'

Benchmark.ips do |x|
  x.config(
    stats: :bootstrap,
    confidence: 95,
  )
  x.report("task 1") do
    work
  end
end
