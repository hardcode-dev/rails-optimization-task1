require 'ruby-prof'
require_relative 'task-1.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work('data30_000.txt', disable_gc: false)
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('ruby-prof-flat_final.txt', 'w+'))

# printer = RubyProf::GraphHtmlPrinter.new(result)
# printer.print(File.open("ruby-prof-graph.html", "w+"))

# printer4 = RubyProf::CallTreePrinter.new(result)
# printer4.print(:profile => 'callgrind')

