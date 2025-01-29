require 'ruby-prof'
require_relative '../task-1.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work(filename: 'data_large.txt', gc_disabled: true)
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)
