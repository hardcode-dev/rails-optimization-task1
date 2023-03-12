require 'ruby-prof'

# RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  puts 'RubyProd calltree'
  work($filename, gc: $gc)
end

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'reports', profile: 'ruby-prof-callgrind')