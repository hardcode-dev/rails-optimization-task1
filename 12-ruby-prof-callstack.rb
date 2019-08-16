require 'ruby-prof'
require_relative 'codes/report'

RubyProf.measure_mode = RubyProf::WALL_TIME

report = Report.new(:callstack)

result = RubyProf.profile do
  report.run
end

printer = RubyProf::CallStackPrinter.new(result)
printer.print(report.file)

report.open
