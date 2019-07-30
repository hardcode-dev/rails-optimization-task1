# RubyProf Flat report
# ruby 10-ruby-prof-flat.rb
# cat ruby_prof_reports/flat.txt
require 'ruby-prof'
require_relative 'work_method'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  GC.disable
  work('data_large.txt')
end
printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open("ruby_prof_reports/flat.txt", "w+"))