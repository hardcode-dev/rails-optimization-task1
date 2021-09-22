# frozen_string_literal: true

require 'ruby-prof'
require_relative 'task_1'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work('data_small.txt', disable_gc: true)
end

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('ruby_prof_reports/graph.html', 'w+'))