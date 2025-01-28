require './work'

time = Time.now
work('data_large.txt')
end_time = Time.now
p end_time - time

# Sorry, decided to keep!
#
# profile with ruby-prof

# require 'ruby-prof'

# GC.disable
# RubyProf.measure_mode = RubyProf::WALL_TIME

# result = RubyProf::Profile.profile do
#   work('data_large.txt')
# end

# printer = RubyProf::CallStackPrinter.new(result)
# printer.print(File.open('ruby_prof_reports/callstack.html', 'w+'))

# profile with stackprof

# profile = StackProf.run(mode: :wall, raw: true) do
#   work('data_large.txt')
# end

# File.write('stackprof_reports/stackprof.json', JSON.generate(profile))


