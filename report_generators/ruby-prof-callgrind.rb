# frozen_string_literal: true

require_relative '../task-1'
require 'ruby-prof'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work('data/data_5000.txt')
end

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'ruby_prof_reports', profile: 'callgrind')
