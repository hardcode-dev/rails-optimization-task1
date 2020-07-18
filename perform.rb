require 'benchmark'
require 'stackprof'
require 'ruby-prof'

require_relative 'task-1'

p 'String process ...'

GC.disable
time = Benchmark.realtime do
  work(file: 'data.txt')
end

p "Finish in #{time.round(2)}"