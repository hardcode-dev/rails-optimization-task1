require_relative 'task-1'
require 'benchmark'

Dir['data_part_*'].sort_by { |f| f[/\d+/].to_i }.each do |file_path|
  puts '===================='
  puts "File: #{file_path}"
  time = Benchmark.realtime { work(file_path) }
  puts time.round(2)
end
