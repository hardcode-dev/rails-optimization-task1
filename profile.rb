require 'ruby-prof'
require 'benchmark'
require_relative 'task-1'
require_relative 'optimized'

TIMES = 100

# (1..100).to_a.each do |i|
#   puts i
#   begin
#     system "head -n #{100 * i} data_large.txt > data/data_#{100 * i}.txt"
#   rescue
#     puts 'skipped'
#     next
#   end
# end

# (1..TIMES).to_a.each do |i|
#   # b.report((100*i).to_s) do
#     time = Benchmark.realtime do
#       Parser.work("data/data_#{100 * i}.txt", gc_disabled: true)
#     end
#
#     puts time.to_s
#   # end
# end

Benchmark.bmbm(10) do |b|
  b.report("work") { TIMES.times { Parser.work('data/data_500.txt', gc_disabled: true) } }
  b.report("optimized") { TIMES.times { ParserOptimized.work('data/data_500.txt', gc_disabled: true) } }
end

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile(track_allocations: true) do
  ParserOptimized.work('data/data_1000.txt', gc_disabled: true)
end

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('reports/ruby-prof-callstack.html', 'w+'))

exec "open #{File.absolute_path('reports/ruby-prof-callstack.html')}"
