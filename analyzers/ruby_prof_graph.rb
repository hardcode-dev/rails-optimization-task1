# frozen_string_literal: true

require 'ruby-prof'
require_relative '../task_1'

RubyProf.measure_mode = RubyProf::WALL_TIME
DEMO_DATA = Dir['analyzers/demo_data/demo_data_100000.t_xt'].freeze

DEMO_DATA.each do |data_path|
  result = RubyProf.profile do
    work(data_path)
  end
  printer = RubyProf::GraphHtmlPrinter.new(result)
  printer.print(File.open("analyzers/reports/ruby_prof_graph_#{data_path.gsub(/[^\d]/, '')}.html", 'w+'))
end
