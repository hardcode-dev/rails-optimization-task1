# frozen_string_literal: true

# RubyProf reports
# brew install qcachegrind
# ruby ruby_prof.rb
# cd reports/ruby_prof
# cat flat.txt
# open graph.html
# open callstack.html
# brew install qcachegrind
# qcachegrind callgrind.callgrind.out...

require 'ruby-prof'
require 'stackprof'
require_relative '../task_1'

FILENAME_SMALL = 'data.txt'
FILENAME_2_500 = 'data_2_500.txt'
FILENAME_5_000 = 'data_5_000.txt'
FILENAME_10_000 = 'data_10_000.txt'
FILENAME_LARGE = 'data_large.txt'

filename = FILENAME_10_000
path = 'profilers/reports/ruby_prof'

# RubyProf
RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work("data/#{filename}", disable_gc: true)
end

printer1 = RubyProf::FlatPrinter.new(result)
printer1.print(File.open("#{path}/flat.txt", 'w+'))

printer2 = RubyProf::GraphHtmlPrinter.new(result)
printer2.print(File.open("#{path}/graph.html", 'w+'))

printer3 = RubyProf::CallStackPrinter.new(result)
printer3.print(File.open("#{path}/callstack.html", 'w+'))

printer4 = RubyProf::CallTreePrinter.new(result)
printer4.print(path: path, profile: 'callgrind')
