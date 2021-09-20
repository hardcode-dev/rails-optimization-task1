require 'ruby-prof'
require_relative '../task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work('data/data_1500000.txt')
end

# print a graph profile to text
printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT, {})

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('benchmark/reports/callstack.html', 'w+'))
