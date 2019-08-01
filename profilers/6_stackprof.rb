# Stackprof report
# ruby profilers/6_stackprof.rb
# cd profilers/stackprof_reports/
# stackprof stackprof.dump
# stackprof stackprof.dump --method Object#work
require_relative '../config/environment'

StackProf.run(mode: :wall, out: 'profilers/stackprof_reports/stackprof.dump', interval: 1000) do
  Task.new(data_file_path: './spec/fixtures/data_10k.txt').work
end

result_file_path = 'data/result.json'
File.delete(result_file_path) if File.exist?(result_file_path)
