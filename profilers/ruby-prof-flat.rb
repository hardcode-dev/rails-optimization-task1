# RubyProf Flat report
# ruby 12-ruby-prof-flat.rb
# cat ruby_prof_reports/flat.txt
require 'ruby-prof'
require_relative '../parser.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME # CPU_TIME
parser = Parser.new(data: 'data/data3250.txt', result: 'data/result.json', disable_gc: true)

result = RubyProf.profile do
  parser.work
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('profilers/ruby_prof_reports/flat.txt', 'w+'))
