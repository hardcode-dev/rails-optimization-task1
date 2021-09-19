require 'ruby-prof'
require_relative 'task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work('fixtures/data_10000.txt', disable_gc: true)
end

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open("raport/callstack.html", "w+"))
