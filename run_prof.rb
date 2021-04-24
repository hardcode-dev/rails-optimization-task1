require_relative 'task-1'.freeze
require 'ruby-prof'

def work_with_rubyprof
  RubyProf.measure_mode = RubyProf::WALL_TIME
  GC.disable
  result = RubyProf.profile do
    work('data_large.txt')
  end

  printer = RubyProf::FlatPrinter.new(result)
  printer.print(File.open('ruby_prof_reports/flat_1000000.txt', 'w+'))

  printer = RubyProf::CallStackPrinter.new(result)
  printer.print(File.open('ruby_prof_reports/call_stack_1000000.html', 'w+'))

  printer = RubyProf::GraphHtmlPrinter.new(result)
  printer.print(File.open('ruby_prof_reports/graph_1000000.html', 'w+'))
end

work_with_rubyprof
