# Stackprof report
# ruby 16-stackprof.rb
# cd stackprof_reports
# stackprof stackprof.dump
# stackprof stackprof.dump --method Object#work
require 'json'
require 'stackprof'
require_relative 'task-1_with_argument.rb'

`head -n #{8000} data_large.txt > data_small.txt`

StackProf.run(mode: :wall, out: 'stackprof_reports/stackprof.dump', interval: 1000) do
  work("data_small.txt")
end

profile = StackProf.run(mode: :wall, raw: true) do
  work("data_small.txt")
end

File.write('stackprof_reports/stackprof.json', JSON.generate(profile))
