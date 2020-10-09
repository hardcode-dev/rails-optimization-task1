require 'benchmark'
require 'ruby-prof'
require 'stackprof'
require_relative 'task-1'


user_counts = [10, 50, 100, 500, 1000]
# GC.disable
user_counts.each do |count|
  user_time = Benchmark.realtime do
    work("data#{count}.txt")
  end
  puts "finished #{count} in #{user_time}"
end

StackProf.run(mode: :wall, out: 'stackprof_reports/sp.dump', interval: 1200) do
  work("data#{500}.txt")
end

RubyProf.measure_mode = RubyProf::WALL_TIME
result = RubyProf.profile do
  work("data#{200}.txt")
end

printer = RubyProf::CallTreePrinter.new(result)
# printer2 = RubyProf::CallStackPrinter.new(result)
printer3 = RubyProf::GraphHtmlPrinter.new(result)

printer.print(path: 'ruby_prof_report', profile: 'callgrid')
# printer2.print(File.open('ruby_prof_report/callstack.html', 'w+'))
printer3.print(File.open('ruby_prof_report/graph.html', 'w+'))
printer4 = RubyProf::FlatPrinter.new(result)
printer4.print(STDOUT)

