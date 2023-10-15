require 'ruby-prof'
require_relative 'task-1'

profile = RubyProf::Profile.new(measure_mode: RubyProf::WALL_TIME)

result = profile.profile do
  work('data10000.txt', disable_gc: true)
end
printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT, min_percent: 2)
