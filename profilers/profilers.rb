require 'json'
require 'stackprof'
require 'ruby-prof'
require_relative '../task-1.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work('./complexity/data10_000.txt')
end

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('ruby_prof_reports/callstack.html', 'w+'))

###############

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
    work('./complexity/data10_000.txt')
end

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open("ruby_prof_reports/graph.html", "w+"))


###############

profile = StackProf.run(mode: :wall, raw: true) do
  work('./complexity/data10_000.txt')
end

File.write('stackprof_reports/stackprof.json', JSON.generate(profile))