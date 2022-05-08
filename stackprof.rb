require 'stackprof'
require_relative 'task-1.rb'

GC.disable

StackProf.run(mode: :wall, out: 'stackprof_reports/stackprof.dump', interval: 1000) do
  work('data/data_4096.txt')
end

# How to read:
# stackprof stackprof_reports/stackprof.dump
# stackprof stackprof_reports/stackprof.dump --method 'Object#work'
