require 'ruby-prof'

# RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  puts 'RubyProd flat'
  work($filename, gc: $gc)
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('reports/ruby-prof-flat.txt', 'w+'))