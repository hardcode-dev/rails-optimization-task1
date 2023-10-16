require 'ruby-prof'
require_relative 'task-1'

profile = RubyProf::Profile.new(measure_mode: RubyProf::WALL_TIME)

result = profile.profile do
  work('data10000.txt', disable_gc: true)
end
printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'ruby_prof_reports', profile: 'callgrind')
