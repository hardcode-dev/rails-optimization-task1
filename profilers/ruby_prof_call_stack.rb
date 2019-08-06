require 'ruby-prof'
require './task1'

result = RubyProf.profile do
  work('spec/fixtures/1000_lines.txt')
end

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('profilers/ruby_prof/callstack.html', 'w+'))

# DOESNT WORK


