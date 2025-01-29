# RubyProf Flat report
# ruby 12-ruby-prof-flat.rb
# cat ruby_prof_reports/flat.txt
require 'ruby-prof'
require_relative 'work_method.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf::Profile.profile do
  work('data_small.txt', disable_gc: true)
end

# Print a Flat profile to text
printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open("ruby_prof_reports/flat.txt", "w+"))

# Print a Graph profile to text
printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open("ruby_prof_reports/graph.html", 'w+'))

# Print a Callstack profile to text
printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open("ruby_prof_reports/callstack.html", "w+"))

# Print a Callgrind profile to text
printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'ruby_prof_reports', profile: 'callgrind')
