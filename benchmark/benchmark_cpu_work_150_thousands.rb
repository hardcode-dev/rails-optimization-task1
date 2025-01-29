# frozen_string_literal: true

require 'benchmark/ips'
require 'benchmark'
require_relative '../task-1'

=begin
puts 'Starting benchmark...'

Benchmark.ips do |x|
  x.config(confidence: 95)

  x.report('Building report') do
    work(file_name: 'data_150_thousands_lines.txt')
  end
end
=end


puts 'Starting benchmark...'

time = Benchmark.realtime do
  work(file_name: 'data_150_thousands_lines.txt')
end

puts "Finish in #{time.round(2)}"
