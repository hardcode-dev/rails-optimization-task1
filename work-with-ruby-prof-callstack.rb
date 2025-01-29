require 'ruby-prof'
require_relative 'task-1'

profile = RubyProf::Profile.new
RubyProf.measure_mode = RubyProf::WALL_TIME
puts "Start work"

GC.disable
result = profile.profile do
  work('data_large.txt')
end

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('ruby_prof_reports/callstack6.html', 'w+'))
puts "End work"
