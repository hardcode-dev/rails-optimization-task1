require 'ruby-prof'
require_relative '../task-1.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work(filename: 'test_data/data100000.txt', gc_disabled: true)
end

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open("tmp/rp_prof_graph_#{Time.now}.html", 'w+'))
