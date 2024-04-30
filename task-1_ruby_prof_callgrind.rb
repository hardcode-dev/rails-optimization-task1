# frozen_string_literal: true

# rubocop:disable all
<<-BASH
  DATA_FILE='data20000.txt' DISABLE_GC=true ruby task-1_ruby_prof_callgrind.rb
  qcachegrind ruby_prof_reports/callgrind.out.49819
  qcachegrind ruby_prof_reports/callgrind.out.50121
BASH
# rubocop:enable all

require 'ruby-prof'
require_relative 'task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf::Profile.profile do
  work(ENV.fetch('DATA_FILE', nil), disable_gc: ENV.fetch('DISABLE_GC', true))
end

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'ruby_prof_reports', profile: 'callgrind')
