require 'ruby-prof'
require_relative 'task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work('fixtures/data_30000.txt', disable_gc: true)
end

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open("raport/graph.html", "w+"))
