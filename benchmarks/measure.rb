require "benchmark"

require_relative "../task-1"

file_name = ENV["FILE_NAME"] || "data.txt"
file_path = File.join(ENV["PWD"], "spec", "fixtures", "data", file_name)

report = Report.new(file_path)

puts Benchmark.measure { report.work }
