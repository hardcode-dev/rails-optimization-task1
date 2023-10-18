require_relative 'setup'

# RubyProf CallStack report
# ruby 14-ruby-prof-callstack.rb
# open ruby_prof_reports/callstack.html
RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile { work(Setup::FILE_PATH, disable_gc: true) }
printer = RubyProf::GraphHtmlPrinter.new(result)
file_path = File.join(Setup::REPORTS_PATH, 'callstack.html')
printer.print(File.open(file_path, 'w+'))

# не заметил разницы с graph
