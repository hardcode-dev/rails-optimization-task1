# Stackprof report -> flamegraph in speedscope
# ruby 17-stackprof-speedscope.rb
require 'json'
require 'stackprof'
require_relative 'task-1.rb'

profile = StackProf.run(mode: :wall, raw: true) do
  work(disable_gc: true)
end

File.write('stackprof_reports/stackprof.json', JSON.generate(profile))
