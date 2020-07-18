require 'ruby-prof'
require_relative '../lib/task-1.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

GC.disable

result = RubyProf.profile do
  work('files/data_16000.txt')
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)
