require 'ruby-prof'
require_relative 'work_method.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

ROWS_COUNT = 10000

result = RubyProf.profile do
  work("data#{ROWS_COUNT}.txt")
end
printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open("ruby_prof_reports/graph#{ROWS_COUNT}.html", "w+"))
