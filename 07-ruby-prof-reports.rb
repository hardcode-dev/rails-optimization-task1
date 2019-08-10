require 'ruby-prof'
require './01-task-1.rb'
require './02-task-1-refactored.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME
GC.disable

result = RubyProf.profile do
  Refactored.new.work('data_bench.txt')
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open("ruby_prof_reports/flat.txt", "w+"))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open("ruby_prof_reports/graph.html", "w+"))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('ruby_prof_reports/callstack.html', 'w+'))

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: "ruby_prof_reports", profile: 'callgrind')