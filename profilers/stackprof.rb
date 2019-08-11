require 'stackprof'
require_relative '../task-1.rb'

StackProf.run(mode: :wall, out: 'reports/stackprof/stackprof.dump', interval: 1000) do
  work(filename: 'data/data_256x.txt', disable_gc: true)
end

profile = StackProf.run(mode: :wall, raw: true) do
  work(filename: 'data/data_256x.txt', disable_gc: true)
end

File.write('reports/stackprof/stackprof.json', JSON.generate(profile))
