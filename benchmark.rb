require 'benchmark'

require 'ruby-prof'
require_relative 'task-1'

File.write('result.json', '')

def prepare_data_file(user_count = 1)
  File.write('data.txt',
             'user,0,Leida,Cira,0
session,0,0,Safari 29,87,2016-10-23
session,0,1,Firefox 12,118,2017-02-27
session,0,2,Internet Explorer 28,31,2017-03-28
session,0,3,Internet Explorer 28,109,2016-09-15
session,0,4,Safari 39,104,2017-09-27
session,0,5,Internet Explorer 35,6,2016-09-01
' * user_count)
end

user_counts = [1, 5, 10, 50, 100, 500]
user_counts.each do |count|
  prepare_data_file(count)
  user_time = Benchmark.realtime do
    work
  end
  puts "finished #{count} user(s) in #{user_time}"
end

# RubyProf.measure_mode = RubyProf::WALL_TIME
#
# result = RubyProf.profile do
#   work
# end
#
# printer = RubyProf::CallTreePrinter.new(result)
#
# printer.print(path: 'ruby_prof_report', profile: 'callgrid')

