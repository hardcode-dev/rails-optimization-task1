require 'ruby-prof'
require_relative '../../task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  GC.disable
  work('../../data.txt')
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open("flat.txt", "w+"))