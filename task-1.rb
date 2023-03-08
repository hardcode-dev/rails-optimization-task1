require "benchmark"
require "stackprof"
require "ruby-prof"
require "pry"

require_relative "./lib/user.rb"

GC.disable
if ARGV.first&.downcase == "profile"
  result = RubyProf.profile do
    work("./data_small.txt")
  end

  printer = RubyProf::MultiPrinter.new(result)
  printer.print(:path => "./reports", :profile => "profile")

  printer = RubyProf::CallTreePrinter.new(result)
  printer.print(:path => "./reports", :profile => "profile")

  printer = RubyProf::CallStackPrinter.new(result)
  printer.print(File.open("./reports/callstack.html", "w+"))

  StackProf.run(mode: :wall, out: 'reports/myapp.dump') do
    work("./data_small.txt")
  end
else
  Benchmark.bm(5) do |x|
    x.report   { work("./data_small.txt") }
  end
end
GC.enable