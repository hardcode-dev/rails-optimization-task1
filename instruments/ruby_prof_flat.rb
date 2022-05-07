# frozen_string_literal: true

require 'ruby-prof'
require_relative '../task_1'
GC.disable

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  Parser.new('specs/fixtures/data_8000.txt')
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('instruments/ruby_prof_reports/flat.txt', 'w+'))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('instruments/ruby_prof_reports/graph.html', 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('instruments/ruby_prof_reports/callstack.html', 'w+'))

GC.enable
