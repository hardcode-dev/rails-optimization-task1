require 'stackprof'
require_relative '../task-1.rb'


report = Report.new('data/data_512x.txt')

StackProf.run(mode: :wall, out: 'reports/stackprof/stackprof.dump', interval: 1000) do
  report.work(disable_gc: true)
end

profile = StackProf.run(mode: :wall, raw: true) do
  report.work(disable_gc: true)
end

File.write('reports/stackprof/stackprof.json', JSON.generate(profile))
