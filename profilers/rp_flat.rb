# frozen_string_literal: true

require 'ruby-prof'
require_relative '../task_1'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('reports/flat.txt', 'w+'))
