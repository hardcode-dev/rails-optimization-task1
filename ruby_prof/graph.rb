require_relative '../task-1'

require 'ruby-prof'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  GC.disable
  work
end
printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open("tmp/ruby_prof/graph_#{Time.now.to_i}.html", 'w+'))
