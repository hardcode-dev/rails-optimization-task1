require 'ruby-prof'
require_relative 'task-1.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

GC.disable
i = ENV['LINES']

result = RubyProf.profile do
  work("data/data_#{i}.txt")
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('ruby_prof_reports/flat.txt', 'w+'))
