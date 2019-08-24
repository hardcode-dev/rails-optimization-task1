require 'ruby-prof'
require_relative '../task-1.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

def result
  result = RubyProf.profile do
    report = Report.new('data/data_512x.txt')
    report.work(disable_gc: true)
  end
end
