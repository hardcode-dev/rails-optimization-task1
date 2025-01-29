require 'stackprof'
require_relative 'task-1'

GC.disable
StackProf.run(mode: :wall, out: 'stackprof_reports/stackprof.dump', interval: 1000) do
  work('data_large.txt')
end
