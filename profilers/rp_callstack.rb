# frozen_string_literal: true

require 'ruby-prof'
require_relative '../task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work
end

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('reports/callstack.html', 'w+'))
