require 'ruby-prof'
require_relative '../task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile(disable_gc: true) do
  work('data_part_5000.txt')
end

require 'fileutils'
FileUtils.mkdir_p "reports/#{ARGV[0]}"

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open("reports/#{ARGV[0]}/flat.txt", 'w+'))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open("reports/#{ARGV[0]}/graph.html", 'w+'))
# `open tmp/graph.html`

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open("reports/#{ARGV[0]}/callstack.html", 'w+'))
