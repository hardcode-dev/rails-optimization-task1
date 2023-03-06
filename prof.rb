# require 'json'
# require 'stackprof'
# require_relative 'user'

# profile = StackProf.run(mode: :wall, raw: true) do
#  work
# end

# File.write('stackprof_reports/stackprof.json', JSON.generate(profile))

# https://www.speedscope.app/

# ====

# require 'stackprof'
# require_relative 'user'

# StackProf.run(mode: :wall, out: 'stackprof_reports/stackprof.dump', interval: 1000) do
#  work
# end

# ====

require 'ruby-prof'
require_relative 'task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
 work
end


printer = RubyProf::CallTreePrinter.new(result)
printer.print(:path => "ruby_prof_reports", :profile => 'callgrind')

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open("ruby_prof_reports/callstack.html", "w+"))


printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open("ruby_prof_reports/graph.html", "w+"))


printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open("ruby_prof_reports/flat.txt", "w+"))
