# frozen_string_literal: true

require 'benchmark'
require_relative '../task_1'

# GC.disable

puts 'Start'
# number_of_lines = [1000, 2000, 4000, 8000, 16_000, 32_000, 64_000]
number_of_lines = [ 64_000]
number_of_lines.each do |lines|
  time = Benchmark.realtime do
    Parser.new("specs/fixtures/data_#{lines}.txt")
  end
  puts "Finish with lines: #{lines} | #{time.round(3)}"
end


time = Benchmark.realtime do
  Parser.new('data_large.txt')
end
puts "Finish with BIG_DATA  | #{time.round(3)}"
