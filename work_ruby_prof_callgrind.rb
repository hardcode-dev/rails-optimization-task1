require_relative 'work'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  Work.new(file: 'data_large.txt').perform
end

printer4 = RubyProf::CallTreePrinter.new(result)
printer4.print(:path => "ruby_prof_reports", :profile => 'callgrind')