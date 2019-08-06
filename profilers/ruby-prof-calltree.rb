require 'ruby-prof'
require_relative '../task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
	GC.disable
	work('data/data_64000.txt')
end

open "ruby_prof_reports/calltree", 'w' do |file|
    RubyProf::CallTreePrinter.new(result).print(file)
end