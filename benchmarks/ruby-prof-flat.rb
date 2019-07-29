# RubyProf Flat report
# ruby 10-ruby-prof-flat.rb
# cat ruby_prof_reports/flat.txt
require 'ruby-prof'
require_relative '../task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work('../data.txt', disable_gc: true)
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open("flat.txt", "w+"))