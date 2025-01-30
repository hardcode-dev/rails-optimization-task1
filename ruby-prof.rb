require 'ruby-prof'
require_relative './task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work('./spec/fixtures/files/dataN.txt')
end

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('./ruby-prof.html', 'w+'))
