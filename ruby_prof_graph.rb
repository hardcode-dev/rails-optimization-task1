# RubyProf Graph report
# ruby 11-ruby-prof-graph.rb
# open ruby_prof_reports/graph.html
require 'ruby-prof'
require_relative 'work_method'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  GC.disable
  work('data_large.txt', 16000)
end

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open("ruby_prof_reports/graph.html", "w+"))