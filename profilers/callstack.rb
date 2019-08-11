require_relative 'rubyprof_base'

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('reports/ruby_prof/callstack.html', 'w+'))
