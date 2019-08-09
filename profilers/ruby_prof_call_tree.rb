require 'ruby-prof'
require './task1'

result = RubyProf.profile do
  work('spec/fixtures/1_000_lines.txt')
end

printer = RubyProf::CallTreePrinter.new(result)
printer.print(File.open("profilers/ruby_prof/graph.html", "w+"))
