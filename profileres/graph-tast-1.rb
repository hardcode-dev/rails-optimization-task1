require 'ruby-prof'
require_relative '../lib/task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

GC.disable

result = RubyProf.profile do
  work('files/data_16000.txt')
end

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('reports/graph_task-1.html', 'w+'))
