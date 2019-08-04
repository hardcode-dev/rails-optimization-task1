require_relative 'work'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  Work.new(file: 'data_large.txt').perform
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open("ruby_prof_reports/flat.txt", "w+"))