require_relative 'rubyprof_base'

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('reports/ruby_prof/graph.html', 'w+'))

