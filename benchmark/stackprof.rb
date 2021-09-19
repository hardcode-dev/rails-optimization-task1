require 'stackprof'
require_relative '../task-1'

StackProf.run(mode: :wall, out: 'benchmark/reports/stackprof.dump', interval: 10) do
  work('data_10000.txt')
end
