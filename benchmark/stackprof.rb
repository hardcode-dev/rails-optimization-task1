require 'stackprof'
require_relative '../task-1'

StackProf.run(mode: :wall, out: 'benchmark/reports/stackprof.dump', interval: 100) do
  work('data/data_500000.txt')
end
