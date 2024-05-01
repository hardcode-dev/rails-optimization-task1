require_relative '../task-1'

require 'ruby-prof'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  GC.disable
  work
end
printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open("tmp/ruby_prof/callstack_#{Time.now.to_i}.html", 'w+'))
