require 'ruby-prof'
require 'stackprof'
require 'json'
require_relative 'task-1.rb'

file_name =  ARGV[0] || 'data100000.txt' 
RubyProf.measure_mode = RubyProf::WALL_TIME
result = RubyProf::Profile.profile do
  work(file_name: file_name, disable_gc: false)
end

# printer = RubyProf::FlatPrinter.new(result)
# printer.print(File.open("reports/flat_cutted/#{file_name.split('.')[0]}.txt", "w+"))

# printer2 = RubyProf::GraphHtmlPrinter.new(result)
# printer2.print(File.open("reports/graph/#{file_name.split('.')[0]}.html", "w+"))

# printer3 = RubyProf::CallStackPrinter.new(result)
# printer3.print(File.open("reports/call_stack/#{file_name.split('.')[0]}.html", "w+"))

printer4 = RubyProf::CallTreePrinter.new(result)

printer4.print(:path => 'reports/call_tree', :profile => file_name.split('.')[0])


# StackProf.run(mode: :wall, out: "reports/stackprof/#{file_name.split('.')[0]}.dump", interval: 1000) do
#   work(disable_gc: true)
# end


# profile = StackProf.run(mode: :wall, raw: true) do
#   work(file_name: file_name, disable_gc: true)  
# end

# File.write("reports/stackprof_json/#{file_name.split('.')[0]}", JSON.generate(profile))