# head -n <N lines> data_large.txt > data_prof.txt
# ruby task-1-ruby-prof-callstack.rb

require 'ruby-prof'
require_relative 'task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work(file_name: "data_prof.txt")
end

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('prof_reports/ruby_prof_callstack.html', 'w+'))
