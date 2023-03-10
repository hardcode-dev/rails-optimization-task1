# RubyProf CallStack report
# ruby 14-ruby-prof-callstack.rb
# open ruby_prof_reports/callstack.html
require 'ruby-prof'
require_relative 'task-1.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work(disable_gc: true)
end

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('ruby_prof_reports/callstack.html', 'w+'))