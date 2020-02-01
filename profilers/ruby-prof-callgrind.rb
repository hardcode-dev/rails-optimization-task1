require 'ruby-prof'
require_relative '../task-1.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

filename = 'data_10_000.txt'

result = RubyProf.profile do
  work(filename, disable_gc: true)
end

printer = RubyProf::CallTreePrinter.new(result)
printer.print(:path => "profilers/ruby_prof_reports", :profile => "callgring_#{filename}.html")
