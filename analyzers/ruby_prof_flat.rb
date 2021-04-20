# frozen_string_literal: true

require 'ruby-prof'
require_relative '../task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

%w[1000 2000 3000].each do |n|
  result = RubyProf.profile do
    work("analyzers/demo_data/data#{n}.txt")
  end
  printer = RubyProf::FlatPrinter.new(result)
  printer.print(File.open("analyzers/reports/ruby_prof_flat#{n}.txt", 'w+'))
end


