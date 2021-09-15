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

RubyProf::FlatPrinter.new(result).print
RubyProf::GraphHtmlPrinter.new(result).print(File.open('report.html', 'w+'))
DataManager.clear_data
#parse_session [5071 calls, 5071 total]
