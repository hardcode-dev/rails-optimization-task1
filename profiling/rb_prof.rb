# frozen_string_literal: true

require_relative '../task-1'
require 'ruby-prof'

result = RubyProf.profile do
  work(input_filename: './profiling/files/data_1Mb', output_filename: '/dev/null')
end

printer = RubyProf::FlatPrinter.new(result)
printer.print($stdout)
