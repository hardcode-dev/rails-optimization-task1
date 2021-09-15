# frozen_string_literal: true

require 'ruby-prof'
require_relative 'task-1'
require_relative 'data_manager'

DataManager.setup_data(6000)
RubyProf.measure_mode = RubyProf::WALL_TIME

GC.disable
result = RubyProf.profile do
  work
end
GC.enable

printer = RubyProf::FlatPrinter.new(result)
printer.print
DataManager.clear_data
