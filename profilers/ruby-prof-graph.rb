# RubyProf Graph report
# ruby profilers/ruby-prof-graph.rb
# open prof_reports/graph.html
require 'ruby-prof'
require_relative '../task-1.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

GC.disable
result = RubyProf.profile do
  work('data_large.txt')
end
GC.enable

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open("prof_reports/graph.html", "w+"))