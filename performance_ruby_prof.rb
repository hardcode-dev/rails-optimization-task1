# frozen_string_literal: true

require 'ruby-prof'
require './task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile(track_allocations: true) do
  work('data_large.txt', gc_disable: true)
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)
