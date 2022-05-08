require 'json'
require 'stackprof'
require_relative 'task-1.rb'

GC.disable
i = ENV['LINES']

profile = StackProf.run(mode: :wall, raw: true) do
  work("data/data_#{i}.txt")
end

File.write('stackprof_reports/stackprof.json', JSON.generate(profile))

# How to read:
# https://speedscope.app
