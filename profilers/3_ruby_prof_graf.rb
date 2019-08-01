# RubyProf Graph report
# ruby profilers/3_ruby_prof_graf.rb
# open profilers/ruby_prof_reports/graph.html
require_relative '../config/environment'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  Task.new(data_file_path: './spec/fixtures/data_10k.txt').work
end

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('profilers/ruby_prof_reports/graph.html', "w+"))

result_file_path = 'data/result.json'
File.delete(result_file_path) if File.exist?(result_file_path)
