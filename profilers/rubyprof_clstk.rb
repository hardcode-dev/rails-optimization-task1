require_relative '../work'
require 'ruby-prof'

GC.disable if ENV['GB_OFF']
profile = RubyProf::Profile.new(measure_mode: RubyProf::WALL_TIME)

profile.start

work("data/data#{ENV['FILE_SIZE']}.txt")

result = profile.stop


printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('profilers/callstack.html', 'w+'))