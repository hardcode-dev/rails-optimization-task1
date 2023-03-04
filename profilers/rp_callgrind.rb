# frozen_string_literal: true

require 'ruby-prof'
require_relative '../task_1'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work('data10000.txt')
end

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'reports', profile: 'callgrind')
