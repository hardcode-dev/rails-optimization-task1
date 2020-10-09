require 'benchmark'
require 'ruby-prof'
require 'stackprof'
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
user,1,Palmer,Katrina,65
session,1,0,Safari 17,12,2016-10-21
session,1,1,Firefox 32,3,2016-12-20
session,1,2,Chrome 6,59,2016-11-11
session,1,3,Internet Explorer 10,28,2017-04-29
session,1,4,Chrome 13,116,2016-12-28
user,2,Gregory,Santos,86
session,2,0,Chrome 35,6,2018-09-21
session,2,1,Safari 49,85,2017-05-22
session,2,2,Firefox 47,17,2018-02-02
session,2,3,Chrome 20,84,2016-11-25
' * user_count)
end

user_counts = [1, 5, 10, 50, 100, 500, 1000]
# GC.disable
user_counts.each do |count|
  prepare_data_file(count)
  user_time = Benchmark.realtime do
    work
  end
  puts "finished #{count} in #{user_time}"
end

StackProf.run(mode: :wall, out: 'stackprof_reports/sp.dump', interval: 1200) do
  work
end

RubyProf.measure_mode = RubyProf::WALL_TIME
prepare_data_file(200)
result = RubyProf.profile do
  work
end

printer = RubyProf::CallTreePrinter.new(result)
# printer2 = RubyProf::CallStackPrinter.new(result)
printer3 = RubyProf::GraphHtmlPrinter.new(result)

printer.print(path: 'ruby_prof_report', profile: 'callgrid')
# printer2.print(File.open('ruby_prof_report/callstack.html', 'w+'))
printer3.print(File.open('ruby_prof_report/graph.html', 'w+'))
printer4 = RubyProf::FlatPrinter.new(result)
printer4.print(STDOUT)

