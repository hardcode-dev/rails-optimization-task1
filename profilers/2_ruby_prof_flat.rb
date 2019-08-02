# ruby profilers/2_ruby_prof_flat.rb
# cat profilers/ruby_prof_reports/flat.txt
require_relative '../config/environment'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  Task.new(data_file_path: './spec/fixtures/data_20k.txt').work
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open("profilers/ruby_prof_reports/flat.txt", "w+"))

result_file_path = 'data/result.json'
File.delete(result_file_path) if File.exist?(result_file_path)
