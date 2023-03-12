require 'ruby-prof'

# RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  puts 'RubyProd callstack'
  work($filename, gc: $gc)
end

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('reports/ruby-prof-callstack.html', 'w+'))