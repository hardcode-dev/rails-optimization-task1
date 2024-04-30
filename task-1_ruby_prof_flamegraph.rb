# frozen_string_literal: true

# rubocop:disable all
# The gem ruby-prof-speedscope (https://github.com/chanzuckerberg/ruby-prof-speedscope)
<<-BASH
  DATA_FILE='data20000.txt' DISABLE_GC=true ruby task-1_ruby_prof_flamegraph.rb
  speedscope ruby_prof_reports/task-1_flamegraph_data_file_data20000.txt_disable_gc_true.json
BASH
# rubocop:enable all

require 'ruby-prof'
require 'ruby-prof-speedscope'
require_relative 'task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf::Profile.profile do
  work(ENV.fetch('DATA_FILE', nil), disable_gc: ENV.fetch('DISABLE_GC', true))
end

params = "data_file_#{ENV.fetch('DATA_FILE', nil)}_disable_gc_#{ENV.fetch('DISABLE_GC', true)}"
File.open("ruby_prof_reports/task-1_flamegraph_#{params}.json", 'w+') do |f|
  RubyProf::SpeedscopePrinter.new(result).print(f)
end
