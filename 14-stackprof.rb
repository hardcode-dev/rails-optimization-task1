# Stackprof report
# ruby 14-stackprof.rb
# cd stackprof_reports
# stackprof stackprof.dump
# stackprof stackprof.dump --method Object#work

require 'stackprof'
require_relative 'codes/report'

report = Report.new(:stackprof)

StackProf.run(mode: :wall, out: report.full_name, interval: 1000) do
  report.run
end
