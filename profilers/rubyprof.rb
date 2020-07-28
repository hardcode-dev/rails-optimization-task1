# frozen_string_literal: true

require 'ruby-prof'
require_relative '../task-1.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

`head -n 12500 data_large.txt > data_large12500.txt`

result = RubyProf.profile do
  work(filename: 'data_large12500.txt', gc: false)
end

RubyProf::FlatPrinter.new(result).print(File.open('reports/rubyprof_flat.txt', 'w+'))
RubyProf::GraphHtmlPrinter.new(result).print(File.open('reports/rubyprof_graph.html', 'w+'))
RubyProf::CallStackPrinter.new(result).print(File.open('reports/rubyprof_callstack.html', 'w+'))
RubyProf::CallTreePrinter.new(result).print(path: 'reports', profile: 'callgrind')

`rm data_large12500.txt`
