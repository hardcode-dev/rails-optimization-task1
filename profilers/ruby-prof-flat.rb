require 'ruby-prof'
require_relative '../task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
	GC.disable
	work('data/data_64000.txt')
end

File.open "ruby_prof_reports/flat2.txt", 'w' do |file|
	RubyProf::FlatPrinter.new(result).print(file)
end

system('cat ruby_prof_reports/flat2.txt')