require 'stackprof'
require 'json'
require_relative 'task-1'

GC.disable
profile = StackProf.run(mode: :wall, raw: true) do
  work
end

File.write('stackprof_reports/stackprof.json', JSON.generate(profile))
