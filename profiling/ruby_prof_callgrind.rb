require_relative 'setup'

# RubyProf CallGrind report
# ruby 15-ruby-prof-callgrind.rb
# brew install qcachegrind
# qcachegrind ruby_prof_reports/...

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile { work(Setup::FILE_PATH, disable_gc: true) }
printer4 = RubyProf::CallTreePrinter.new(result)
printer4.print(:path => Setup::REPORTS_PATH, :profile => 'callgrind')
