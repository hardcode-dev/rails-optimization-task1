#!/usr/bin/env ruby

# require 'benchmark'

# Benchmark.bm do |x|
#   x.report { work('sample100.txt') }
#   x.report { work('sample1000.txt') }
#   x.report { work('sample10000.txt') }
# end

require_relative 'task-1.rb'
require 'ruby-prof'

profile = RubyProf::Profile.new(measure_mode: RubyProf::WALL_TIME)
GC.disable

result = profile.profile do
  work('data_small.txt')
end

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('ruby_prof_result/graph9.html', 'w+'))
