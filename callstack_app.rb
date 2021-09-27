require_relative 'config/environment'

RubyProf.measure_mode = RubyProf::WALL_TIME

GC.disable

result = RubyProf.profile do
  GenerateReport.new.work('spec/support/fixtures/data_128000.txt')
end

GC.enable

File.open(
  "/home/artur/Thinknetica/optimization/lesson-01/rails-optimization-task1/profiler_reports/test_callstack.html",
  'w+'
) do |file|
  RubyProf::CallStackPrinter.new(result).print(file)
end
