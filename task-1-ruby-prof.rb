require_relative 'task-1'
require 'ruby-prof'

GC.disable
RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work('data_part_13122.txt')
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('ruby_prof_reports/flat.txt', 'w+'))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('ruby_prof_reports/graph.html', 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('ruby_prof_reports/callstack.html', 'w+'))

GC.enable