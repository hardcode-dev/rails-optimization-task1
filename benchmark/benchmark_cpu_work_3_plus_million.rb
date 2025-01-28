# frozen_string_literal: true

require 'benchmark'
require_relative '../task-1'

puts 'Starting benchmark...'

time = Benchmark.realtime do
  work(file_name: 'data_large.txt')
end

puts "Finish in #{time.round(2)}"

