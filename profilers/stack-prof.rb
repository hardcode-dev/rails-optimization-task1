require 'stackprof'
require_relative '../task-1'


StackProf.run(mode: :wall, out: 'stack_prof_reports/stp.dump', interval: 1000) do
  GC.disable
  work('data/data_64000.txt')
end

system ('stackprof stack_prof_reports/stp.dump')
system ('stackprof stack_prof_reports/stp.dump --method Object#work')
