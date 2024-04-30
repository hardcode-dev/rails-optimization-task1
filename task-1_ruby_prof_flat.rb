# frozen_string_literal: true

# rubocop:disable all
<<-BASH
  DATA_FILE='data20000.txt' DISABLE_GC=true ruby task-1_ruby_prof_flat.rb
BASH
# rubocop:enable all

require 'ruby-prof'
require_relative 'task-1'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf::Profile.profile do
  work(ENV.fetch('DATA_FILE', nil), disable_gc: ENV.fetch('DISABLE_GC', true))
end

printer = RubyProf::FlatPrinter.new(result)
params = "data_file_#{ENV.fetch('DATA_FILE', nil)}_disable_gc_#{ENV.fetch('DISABLE_GC', true)}"
printer.print(File.open("ruby_prof_reports/task-1_flat_#{params}.txt", 'w+'))
