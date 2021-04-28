# Stackprof report -> flamegraph in speedscope
# ruby 17-stackprof-speedscope.rb
# https://www.speedscope.app/
require 'json'
require 'stackprof'
require_relative '../parser.rb'

parser = Parser.new(data: 'data/data3250.txt', result: 'data/result.json', disable_gc: true)

profile = StackProf.run(mode: :wall, raw: true) do
  parser.work
end

File.write('profilers/stackprof_reports/stackprof.json', JSON.generate(profile))
