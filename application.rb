require_relative 'config/environment'

# ---RUBYPROF START---
RubyProf.measure_mode = RubyProf::WALL_TIME

GC.disable

result = RubyProf.profile do
  GenerateReport.new.work('data.txt')
end

GC.enable

File.open(
  "/home/artur/Thinknetica/optimization/lesson-01/rails-optimization-task1/profiler_reports/ruby-prof_html_graph_report.html",
  'w+'
) do |file|
  RubyProf::GraphHtmlPrinter.new(result).print(file)
end
# ---RUBYPROF END---

# ---STACKPROF START---
# StackProf.run(
#   mode: :wall,
#   out: '/home/artur/Thinknetica/optimization/lesson-01/rails-optimization-task1/profiler_reports/stack-prof_cli_report.dump',
#   interval: 1000
# ) do
#   GC.disable
#   GenerateReport.new.work('data.txt')
#   GC.enable
# end
# ---STACKPROF END---
