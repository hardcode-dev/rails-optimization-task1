require 'benchmark'

time = Benchmark.realtime do
  %x( ruby task-1.rb )
end

puts "finished in #{time.round(2)}"
