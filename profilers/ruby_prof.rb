require 'ruby-prof'
require_relative '../task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  GC.disable
  work(file_lines: File.read('data.txt').split("\n"))
end

printer_flat = RubyProf::FlatPrinter.new(result)
printer_flat.print(File.open("ruby_prof_reports/flat.txt", "w+"))

printer_graph = RubyProf::GraphHtmlPrinter.new(result)
printer_graph.print(File.open("ruby_prof_reports/graph.html", "w+"))

printer_callstack = RubyProf::CallStackPrinter.new(result)
printer_callstack.print(File.open('ruby_prof_reports/callstack.html', 'w+'))
