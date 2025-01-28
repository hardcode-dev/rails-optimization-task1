require 'benchmark/ips'
#require 'kalibera'
require 'benchmark'
require_relative '../task-1'

=begin
puts 'Starting benchmark...'

Benchmark.ips do |x|
  x.config(confidence: 95)

  x.report('Building report') do
    work(file_name: 'data_25000_thousands_lines.txt')
  end
end
=end

puts 'Starting benchmark...'

time = Benchmark.realtime do
  work(file_name: 'data_25000_thousands_lines.txt')
end

puts "Finish in #{time.round(2)}"
