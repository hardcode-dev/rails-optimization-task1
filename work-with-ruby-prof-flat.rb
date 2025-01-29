require 'ruby-prof'
require_relative 'task-1'

profile = RubyProf::Profile.new
RubyProf.measure_mode = RubyProf::WALL_TIME
puts "Start work"

GC.disable
result = profile.profile do
  work
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('ruby_prof_reports/flat1.txt', 'w+'))
puts "End work"
