require 'ruby-prof'

# RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  puts 'RubyProd graph'
  work($filename, gc: $gc)
end

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('reports/ruby-prof-graph.html', 'w+'))