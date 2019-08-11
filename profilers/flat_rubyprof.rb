require_relative 'rubyprof_base'

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('reports/ruby_prof/flat.txt', 'w+'))

