# RubyProf Flat report
# ruby profilers/ruby-prof-flat.rb
# cat ruby_prof_reports/flat.txt
require 'ruby-prof'
require_relative '../task-1.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

GC.disable
result = RubyProf.profile do
  work('data_big.txt')
end
GC.enable

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open("prof_reports/flat.txt", "w+"))