require 'stackprof'
require_relative 'work_method.rb'

ROWS_COUNT = 100000

StackProf.run(mode: :wall, out: "stackprof_reports/stackprof.dump", interval: 1000) do
  work("data#{ROWS_COUNT}.txt")
end
