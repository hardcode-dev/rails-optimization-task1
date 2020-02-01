require 'json'
require 'stackprof'
require_relative 'task-1'

profile = StackProf.run(mode: :wall, raw: true) do
  work
end

File.write('stackprof_reports/stackprof.json', JSON.generate(profile))