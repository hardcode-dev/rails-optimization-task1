require 'stackprof'
require_relative 'task-1'

StackProf.run(mode: :wall, out: 'stackprof_reports/stackprof.dump', interval: 1000) do
  work(file_name: 'data_10_000.txt', disabled_gc: true)
end
