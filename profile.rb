require_relative 'work'
# require 'ruby-prof'
#
# RubyProf.measure_mode = RubyProf::WALL_TIME
#
# result = RubyProf.profile do
#   work('test/data/data_5000.txt')
# end
#
# printer = RubyProf::CallStackPrinter.new(result)
# printer.print(File.open('ruby_prof_reports/callstack.html', 'w+'))

require 'json'
require 'stackprof'

profile = StackProf.run(mode: :wall, raw: true) do
  work('test/data/data_5000.txt')
end

File.write('stackprof_reports/stackprof.json', JSON.generate(profile))