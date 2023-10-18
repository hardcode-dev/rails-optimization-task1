require_relative 'setup'

# RubyProf Graph report
# ruby 13-ruby-prof-graph.rb
# open ruby_prof_reports/graph.html

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile { work(Setup::FILE_PATH, disable_gc: true) }

printer = RubyProf::GraphHtmlPrinter.new(result)
file_path = File.join(Setup::REPORTS_PATH, 'graph.html')
printer.print(File.open(file_path, "w+"))
