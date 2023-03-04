require 'ruby-prof'
require_relative '../task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work('data/data-20000-lines.txt', disable_gc: true)
end

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('reports/callstack.html', 'w+'))

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('reports/flat.txt', 'w+'))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('reports/graph.html', 'w+'))

