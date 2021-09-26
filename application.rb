require_relative 'config/environment'

GenerateReport.new.work('spec/support/fixtures/data_large.txt')

# ---RUBYPROF START---
# RubyProf.measure_mode = RubyProf::WALL_TIME

# GC.disable

# result = RubyProf.profile do
#   GenerateReport.new.work('spec/support/fixtures/data_large.txt')
# end

# GC.enable

# File.open(
#   "/home/artur/Thinknetica/optimization/lesson-01/rails-optimization-task1/profiler_reports/flat_16000.html",
#   'w+'
# ) do |file|
#   RubyProf::FlatPrinter.new(result).print(file)
# end
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
