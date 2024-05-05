# Stackprof report
# ruby 16-stackprof.rb
# cd stackprof_reports
# stackprof stackprof.dump
# stackprof stackprof.dump --method Object#work
require 'json'
require 'stackprof'
require_relative 'work_method.rb'

# stackprof CLI
StackProf.run(mode: :wall, out: 'stackprof_reports/stackprof.dump', interval: 1000) do
  work('data_small.txt', disable_gc: true)
end

# stackprof speedscpe
profile = StackProf.run(mode: :wall, raw: true) do
  work('data_small.txt', disable_gc: true)
end

File.write('stackprof_reports/stackprof.json', JSON.generate(profile))
