require 'ruby-prof'
require_relative '../task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
	GC.disable
	work('data/data_64000.txt')
end

File.open "ruby_prof_reports/graph.html", 'w' do |file|
	RubyProf::GraphHtmlPrinter.new(result).print(file)
end

system('open ruby_prof_reports/graph.html')