# RubyProf CallStack report
# ruby 12-ruby-prof-callstack.rb
# open ruby_prof_reports/callstack.txt
require 'ruby-prof'
require_relative 'work_method'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  GC.disable
  work('data_large.txt', 16000)
end

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('ruby_prof_reports/callstack.html', 'w+'))