require_relative 'task-1'
require 'stackprof'

GC.disable
# StackProf.run(mode: :wall, out: 'stackprof_reports/stackprof.dump', interval: 1000) do
#   work('data_part_13122.txt')
# end

profile = StackProf.run(mode: :wall, raw: true, interval: 100) do
  work('data_part_13122.txt')
end

File.write('stackprof_reports/stackprof.json', JSON.generate(profile))
GC.enable