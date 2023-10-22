require 'ruby-prof'
require_relative 'task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work(path: 'data.txt', disable_gc: true)
end

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('ruby_prof_reports/callstack.html', 'w+'))
