require_relative 'config/environment'

RubyProf.measure_mode = RubyProf::WALL_TIME

GC.disable

result = RubyProf.profile do
  GenerateReport.new.work('spec/support/fixtures/data_64000.txt')
end

GC.enable

File.open(
  "/home/artur/Thinknetica/optimization/lesson-01/rails-optimization-task1/profiler_reports/test_flat.txt",
  'w+'
) do |file|
  RubyProf::FlatPrinter.new(result).print(file)
end
