require 'ruby-prof'
require_relative 'task-1.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

GC.disable
i = ENV['LINES']

result = RubyProf.profile do
  work("data/data_#{i}.txt")
end

# How to read:
# brew install qcachegrind
# qcachegrind ruby_prof_reports/<file>
printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'ruby_prof_reports', profile: 'callgrind')
