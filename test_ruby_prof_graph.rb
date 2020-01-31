require 'ruby-prof'
require_relative 'task-1.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work("data50000.txt")
end
printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open("ruby-prof/graph.html", "w+"))


