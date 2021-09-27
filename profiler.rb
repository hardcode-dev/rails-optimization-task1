require 'ruby-prof'
require_relative './task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

results = RubyProf.profile do
  work('data50000.txt', disable_gc: true)
end

RubyProf::MultiPrinter.new(
  results, %i[flat graph graph_html tree call_info stack dot]
).print(path: './reports', profile: 'profile')
