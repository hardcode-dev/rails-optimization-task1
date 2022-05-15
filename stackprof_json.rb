require 'stackprof'
require 'json'
require_relative 'task-1'

profile = StackProf.run(mode: :wall, raw: true) do
  work(file_name: 'data_10_000.txt', disabled_gc: true)
end

File.write('stackprof_reports/stackprof.json', JSON.generate(profile))
