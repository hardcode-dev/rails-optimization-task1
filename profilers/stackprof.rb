require 'json'
require 'stackprof'
require_relative '../task-1'

StackProf.run(mode: :wall, out: 'stackprof_reports/stackprof.dump', interval: 1000) do
  GC.disable
  work(file_lines: File.read('data.txt').split("\n"))
end

profile = StackProf.run(mode: :wall, raw: true) do
  GC.disable
  work(file_lines: File.read('data.txt').split("\n"))
end

File.write('stackprof_reports/stackprof.json', JSON.generate(profile))
