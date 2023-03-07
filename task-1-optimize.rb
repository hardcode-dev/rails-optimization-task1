require "benchmark"
require "stackprof"
require "ruby-prof"

require_relative "./lib/user.rb"
  
GC.disable
Benchmark.bm(5) do |x|
  x.report   { work("./data_small.txt") }
end

# StackProf.run(mode: :wall, out: 'myapp.dump') do
#   work("./data_small.txt")
# end
GC.enable