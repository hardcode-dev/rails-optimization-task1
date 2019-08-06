require 'ruby-prof'
require_relative '../task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
	GC.disable
	work('data/data_64000.txt')
end

File.open "ruby_prof_reports/callstack.html", 'w' do |file|
	RubyProf::CallStackPrinter.new(result).print(file)
end

system('open ruby_prof_reports/callstack.html')