require 'ruby-prof'
require 'stackprof'
require_relative 'task-1.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work('data_small.txt', disable_gc: true)
end

printer4 = RubyProf::CallTreePrinter.new(result)
printer4.print(:profile => 'callgrind')

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open("graph.html", "w+"))
