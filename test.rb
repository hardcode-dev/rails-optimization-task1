#!/usr/bin/env ruby
# frozen_string_literal: true

require 'benchmark'

require_relative 'task-1'
# require 'ruby-prof'

Benchmark.bm do |x|
  x.report { work('data_large.txt') }
end

# profile = RubyProf::Profile.new(measure_mode: RubyProf::WALL_TIME)
# GC.disable

# result = profile.profile do
# work('data_large.txt')
# end

# printer = RubyProf::GraphHtmlPrinter.new(result)
# printer.print(File.open('ruby_prof_result/graph21.html', 'w+'))
