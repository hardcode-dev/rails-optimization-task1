require 'benchmark'
require_relative 'work'

Benchmark.bm do |x|
  x.report("Total time: ") { Work.new(file: 'data_large.txt').perform }
end

# Attempts:
# 1 – 2,3s
# 2 – 1,25s
# 3 – 1,15
# 4 – 0,93
