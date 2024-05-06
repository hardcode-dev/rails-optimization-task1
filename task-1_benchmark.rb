# frozen_string_literal: true

require 'benchmark'
require_relative 'task-1'

files = %w[data5000.txt data10000.txt data15000.txt data20000.txt]
times = []

files.each do |file_name|
  time = Benchmark.realtime do
    work(file_name, disable_gc: true)
  end
  times << "#{file_name} finish in #{time.round(2)}"
end

times.each do |time|
  pp time
end
