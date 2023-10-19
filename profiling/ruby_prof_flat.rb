require_relative 'setup'

# RubyProf Flat report
# ruby 12-ruby-prof-flat.rb
# cat ruby_prof_reports/flat.txt
RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile { work(Setup::FILE_PATH, disable_gc: true) }
printer = RubyProf::FlatPrinter.new(result)
file_path = File.join(Setup::REPORTS_PATH, 'flat.txt')
file = File.open(file_path, "w+")
printer.print(file)
