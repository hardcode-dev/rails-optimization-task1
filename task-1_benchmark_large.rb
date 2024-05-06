# frozen_string_literal: true

# ruby task-1_benchmark_large.rb
# ruby task-1_benchmark_large.rb data_large.txt

require 'benchmark'
require_relative 'task-1'

file_name = ARGV[0] || 'data500_000.txt'

time = Benchmark.realtime do
  work(file_name, disable_gc: false)
end
pp "#{file_name} finish in #{time.round(2)}"
