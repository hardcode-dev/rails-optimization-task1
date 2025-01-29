require_relative '../work'
require 'stackprof'

GC.disable if ENV['GB_OFF']

StackProf.run(mode: :wall, out: 'profilers/stackprof.dump', interval: 1000) do
  work("data/data#{ENV['FILE_SIZE']}.txt")
end
