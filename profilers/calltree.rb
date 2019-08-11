require_relative 'rubyprof_base'

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'reports/ruby_prof/', profile: 'callgrind')

