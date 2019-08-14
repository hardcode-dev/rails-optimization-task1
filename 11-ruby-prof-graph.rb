require 'ruby-prof'
require_relative 'codes/report'

RubyProf.measure_mode = RubyProf::WALL_TIME

report = Report.new(:graph)

result = RubyProf.profile do
  report.run
end

printer_graph = RubyProf::GraphHtmlPrinter.new(result)
printer_graph.print(report.file)
