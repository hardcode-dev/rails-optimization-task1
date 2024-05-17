# Deoptimized version of homework task

require 'ruby-prof'
require_relative 'task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME
GC.disable

result = RubyProf.profile do
  work
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('reports/flat/flat10000_3.txt', 'w+'))
printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('reports/graph/graph10000_3.html', 'w+'))
# printer = RubyProf::CallStackPrinter.new(result)
# printer.print(File.open('reports/callstack10000_1.html', 'w+'))
printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'reports/callgrind', profile: 'callgrind')
