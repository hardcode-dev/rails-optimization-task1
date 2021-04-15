require 'ruby-prof'
require 'benchmark'
require_relative 'task-1'
require_relative 'optimized'

TIMES = 100

Benchmark.bmbm(10) do |b|
  b.report("work") { TIMES.times { Parser.work('data500.txt', gc_disabled: true) } }
  b.report("optimized") { TIMES.times { ParserOptimized.work('data500.txt', gc_disabled: true) } }
end

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile(:track_allocations => true) do
  ParserOptimized.work('data500.txt', gc_disabled: true)
end

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('reports/ruby-prof-graph.html', 'w+'))

# exec "open #{File.absolute_path('reports/ruby-prof-graph.html')}"
