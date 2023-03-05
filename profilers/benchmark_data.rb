require 'benchmark'
require_relative '../task-1'

def time(name, &block)
  time = Benchmark.realtime do
    block.call
  end

  puts "#{name} Completed in #{time.round(3)} ms"
end

[20000, 40000, 60000, 80000, 100_000].each do |line|
  time(line) { work("data/data-#{line}-lines.txt") }
end
