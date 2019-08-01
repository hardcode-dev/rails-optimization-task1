# Stackprof report -> flamegraph in speedscope
# ruby profilers/7_stackprof_speedscope.rb
# Open via browser speedscope.app

require_relative '../config/environment'

profile = StackProf.run(mode: :wall, raw: true) do
  Task.new(data_file_path: './spec/fixtures/data_10k.txt').work
end

File.write('profilers/stackprof_reports/stackprof.json', JSON.generate(profile))
result_file_path = 'data/result.json'
File.delete(result_file_path) if File.exist?(result_file_path)
