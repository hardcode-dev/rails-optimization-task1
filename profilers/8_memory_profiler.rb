require_relative '../config/environment'

MemoryProfiler.start

Task.new(data_file_path: './spec/fixtures/data_10k.txt').work

report = MemoryProfiler.stop
report.pretty_print

result_file_path = 'data/result.json'
File.delete(result_file_path) if File.exist?(result_file_path)
