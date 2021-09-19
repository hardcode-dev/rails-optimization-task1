require 'ruby-prof'
require 'json'
require 'stackprof'

require_relative '../work.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work(filename: 'data_test.txt', disable_gc: true)
end

# printer = RubyProf::FlatPrinter.new(result)
# printer.print(File.open("reports/flat.txt", "w+"))
#
# printer = RubyProf::GraphHtmlPrinter.new(result)
# printer.print(File.open("reports/graph.html", "w+"))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open("reports/callstack-#{Time.now.to_i}.html", "w+"))

# printer = RubyProf::CallTreePrinter.new(result)
# printer.print(path: 'reports', profile: 'callgrind')

profile = StackProf.run(mode: :wall, raw: true, interval: 100) do
  work(filename: 'data_test.txt', disable_gc: true)
end

File.write("reports/stackprof-#{Time.now.to_i}.json", JSON.generate(profile))
