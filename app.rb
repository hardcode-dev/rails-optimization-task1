require_relative 'task-1'

require 'benchmark'
require 'benchmark/ips'

require 'ruby-prof'

RubyProf.measure_mode = RubyProf::WALL_TIME

GC.disable
result = RubyProf.profile do
  work('data10000.txt')
end

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open("ruby_prof_reports_graph.html", "w+"))
puts "Finish"

# Benchmark.ips do |x|
#   x.config(
#     stats: :bootstrap,
#     confidence: 95
#   )
#
#   x.report("parse sessions") do
#     work('data1000.txt')
#   end
# end

# time = Benchmark.realtime do
#   work('data1000.txt')
# end
# puts "Finish in #{time.round(2)}"

