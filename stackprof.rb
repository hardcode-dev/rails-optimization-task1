require_relative './task-1'
require 'stackprof'

StackProf.run(mode: :wall, out: './stackprof.dump', interval: 1000) do
  GC.disable
  work('./spec/fixtures/files/dataN.txt')
end
