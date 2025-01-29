require 'ruby-prof'
require 'stackprof'
require_relative 'task-1.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work('data_large.txt', 'result.json', rows_count: ARGV.first.to_i, gc_disable: true)
end

RubyProf::FlatPrinter.new(result).print(File.open("flat.txt", "w+"))
RubyProf::GraphHtmlPrinter.new(result).print(File.open("graph.html", "w+"))
RubyProf::CallStackPrinter.new(result).print(File.open('callstack.html', 'w+'))
RubyProf::CallTreePrinter.new(result).print(profile: 'callgrind')

profile = StackProf.run(mode: :wall, out: 'stackprof.dump', interval: 1000) do
  work('data_large.txt', 'result.json', rows_count: ARGV.first.to_i, gc_disable: true)
end

File.write('stackprof.json', JSON.generate(profile))