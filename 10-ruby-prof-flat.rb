require 'ruby-prof'
require_relative 'codes/report'

RubyProf.measure_mode = RubyProf::WALL_TIME

report = Report.new(:flat)

result = RubyProf.profile do
  report.run
end

printer_graph = RubyProf::FlatPrinter.new(result)
printer_graph.print(report.file)
