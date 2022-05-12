require 'ruby-prof'
require_relative '../task-1.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME
# profile the code

GC.disable

result = RubyProf.profile do
  work('./benchmarking/support/data_8k.txt')
end

# print a graph profile to text
# printer = RubyProf::GraphPrinter.new(result)

printer = RubyProf::GraphHtmlPrinter.new(result)
File.open('./.ruby_prof_reports/ghaph.html', 'w+') do |f|
  printer.print(f)
  puts "Your report: #{f.path}"
end
