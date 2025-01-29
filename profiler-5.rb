require 'stackprof'
require_relative 'task-1'

StackProf.run(mode: :wall, out: 'stackprof_reports/stackprof.dump', interval: 1000) do
  work('data10000.txt', disable_gc: true)
end
