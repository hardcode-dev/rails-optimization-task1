require 'ruby-prof'
require 'pry'
require_relative 'task-1.rb'

result = RubyProf::Profile.profile(measure_mode: RubyProf::WALL_TIME) do
  work('data_50_000.txt',disable_gc: true)
end

call_stack_printer = RubyProf::CallStackPrinter.new(result)
call_stack_printer.print(File.open('profiles/call_stack_profile.html', 'w+'))

flat_printer = RubyProf::FlatPrinter.new(result)
flat_printer.print(File.open('profiles/flat_stack_profile.txt', 'w+'))