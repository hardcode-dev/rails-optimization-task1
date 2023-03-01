# frozen_string_literal: true

require 'ruby-prof'
require_relative 'task-1'

# GC.disable
result = RubyProf::Profile.profile(track_allocations: true) { work('data_large.txt') }
# GC.enable

RubyProf::GraphHtmlPrinter.new(result).print(
  File.open('reports/ruby-prof-graph.html', 'w'),
  sort_method: :self_time
)
RubyProf::CallStackPrinter.new(result).print(
  File.open('reports/ruby-prof-callstack.html', 'w')
)
