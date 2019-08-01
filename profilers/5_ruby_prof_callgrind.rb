# RubyProf CallGrind report
# ruby profilers/5_ruby_prof_callgrind.rb

# brew install qcachegrind
# qcachegrind profilers/ruby_prof_reports/...

require_relative '../config/environment'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  Task.new(data_file_path: './spec/fixtures/data_10k.txt').work
end

printer4 = RubyProf::CallTreePrinter.new(result)
printer4.print(path: 'profilers/ruby_prof_reports', profile: 'callgrind')

result_file_path = 'data/result.json'
File.delete(result_file_path) if File.exist?(result_file_path)
