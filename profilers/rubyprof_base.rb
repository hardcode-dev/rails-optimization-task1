require 'ruby-prof'
require_relative '../task-1.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

def result
  result = RubyProf.profile do
    work(filename: 'data/data_256x.txt', disable_gc: true)
  end
end
