require 'ruby-prof'
require_relative 'task-1.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

res = RubyProf.profile do
  work('files/data_10000.txt', disable_gc: true)
end

printer = RubyProf::FlatPrinter.new(res)
printer.print(File.open("ruby_prof_reports/flat.txt", "w+"))

printer = RubyProf::GraphHtmlPrinter.new(res)
printer.print(File.open("ruby_prof_reports/graph.html", "w+"))

printer = RubyProf::CallStackPrinter.new(res)
printer.print(File.open("ruby_prof_reports/callstack.html", "w+"))