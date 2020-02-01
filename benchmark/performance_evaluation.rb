require 'benchmark'
require 'benchmark/ips'
require_relative '../task-1.rb'


puts "Start"

time = Benchmark.realtime do
  work(rows_count: 1000)
end

puts "Finish in #{time.round(2)}"

Benchmark.ips do |x|
  x.config(
    stats: :bootstrap,
    confidence: 95,
  )

  x.report('method work with 1000 rows') do
    work(rows_count: 1000)
  end
end