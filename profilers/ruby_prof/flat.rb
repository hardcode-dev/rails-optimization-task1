# frozen_string_literal: true

require 'ruby-prof'

require_relative '../../task-1'
require_relative '../../scripts/profilers_setup'

RubyProf.measure_mode = RubyProf::WALL_TIME

file_path = profilers_setup
result = RubyProf.profile { work(file_path: file_path, disable_gc: true) }

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('reports/ruby_prof/flat.txt', 'w+'))
