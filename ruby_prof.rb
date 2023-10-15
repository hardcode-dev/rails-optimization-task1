# frozen_string_literal: true

require 'ruby-prof'
require_relative 'task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  file_lines = File.read('data_large.txt').split("\n").first(10_000)
  collect_stats(file_lines)
end

# _#{Time.new.to_i}
printer1 = RubyProf::FlatPrinter.new(result)
printer1.print(File.open("ruby_prof_reports/flat_#{Time.new.to_i}.txt", 'w+'))

printer2 = RubyProf::GraphHtmlPrinter.new(result)
printer2.print(File.open("ruby_prof_reports/graph_#{Time.new.to_i}.html", 'w+'))

printer3 = RubyProf::CallStackPrinter.new(result)
printer3.print(File.open("ruby_prof_reports/callstack_#{Time.new.to_i}.html", 'w+'))

printer4 = RubyProf::CallTreePrinter.new(result)
printer4.print(:path => "ruby_prof_reports", :profile => 'callgrind')
