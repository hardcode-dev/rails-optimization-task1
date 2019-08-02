require 'benchmark'
require 'ruby-prof'
require_relative '../lib/parser'

lines = 20000
`head -#{lines} ../data_large.txt > profiling/#{lines}.txt`
puts "#{lines} lines:"
Benchmark.bm do |x|
  x.report { Parser.new(file_path: "profiling/#{lines}.txt").work }
  x.report { Parser.new(file_path: "../data_large.txt").work }
end

# RubyProf.measure_mode = RubyProf::WALL_TIME
#
# result = RubyProf.profile do
#   Parser.new(file_path: "profiling/#{lines}.txt").work
# end

# printer = RubyProf::FlatPrinter.new(result)
# printer.print(File.open("profiling/flat.txt", "w+"))

# printer = RubyProf::GraphHtmlPrinter.new(result)
# printer.print(File.open("profiling/graph.html", "w+"))
#
# printer = RubyProf::CallStackPrinter.new(result)
# printer.print(File.open("profiling/callstack.html", "w+"))

# printer = RubyProf::GraphPrinter.new(result)
# printer.print(File.open("profiling/graph.txt", "w+"))
#
# printer = RubyProf::CallStackPrinter.new(result)
# printer.print(File.open("profiling/calltree.callgrind", "w+"))
