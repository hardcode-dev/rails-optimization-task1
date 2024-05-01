require_relative '../task-1'

require 'ruby-prof'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  GC.disable
  work
end
printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'tmp/ruby_prof', profile: 'callgrind')
