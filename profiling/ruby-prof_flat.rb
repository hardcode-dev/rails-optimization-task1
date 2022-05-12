require 'ruby-prof'
require_relative '../task-1.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME
# profile the code

GC.disable

result = RubyProf.profile do
  work('./benchmarking/support/data_8k.txt')
end

printer = ::RubyProf::FlatPrinter.new(result)
printer.print(STDOUT, {})
