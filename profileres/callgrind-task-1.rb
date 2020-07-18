require 'ruby-prof'
require_relative '../lib/task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

GC.disable

result = RubyProf.profile do
  work('files/data_16000.txt')
end

printer4 = RubyProf::CallTreePrinter.new(result)
printer4.print(path: 'reports', profile: 'callgrind')
