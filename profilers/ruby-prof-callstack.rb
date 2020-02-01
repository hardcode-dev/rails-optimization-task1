require 'ruby-prof'
require_relative '../task-1.rb'
require 'pry'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work('data_1_000.txt', disable_gc: true)
end

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('profilers/ruby_prof_reports/callstack.html', 'w+'))
