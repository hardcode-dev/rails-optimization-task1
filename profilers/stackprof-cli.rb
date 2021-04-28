# Stackprof report
# ruby 16-stackprof.rb
# cd stackprof_reports
# stackprof stackprof.dump
# stackprof stackprof.dump --method Object#work
require 'stackprof'
require_relative '../parser.rb'

parser = Parser.new(data: 'data/data3250.txt', result: 'data/result.json', disable_gc: true)

StackProf.run(mode: :wall, out: 'profilers/stackprof_reports/stackprof.dump', interval: 1000) do
  parser.work
end
