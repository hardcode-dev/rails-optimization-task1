require 'benchmark'
require_relative '../task-1'

def time(name, &block)
  time = Benchmark.realtime do
    block.call
  end

  puts "#{name} Completed in #{time.round(3)} ms"
end

[2000, 4000, 6000, 8000, 10000, 12000, 14000, 16000, 18000, 20000].each do |line|
  time(line) { work("data/data-#{line}-lines.txt") }
end
