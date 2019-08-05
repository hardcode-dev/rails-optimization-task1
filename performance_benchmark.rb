require 'benchmark'
require_relative 'work'

Benchmark.bm do |x|
  x.report("Total time: ") { Work.new(file: 'data_large.txt').perform }
end

# Attempts (20_000 items):
# 1 – 13   # initial
# 2 – 2,3  # remove #select for getting user sessions
# 3 – 1,25 # refactor of parsing user
# 4 – 1,15 # remove deoptimized checking of uniqueBrowsers with #all?
# 5 – 0,89 # remove redudant #split's on parsing users & sessions
# 6 - 0,86 # replace #collect_stats_from_users with one call
# 7 – 0,77 # remove unnecessary #maps and useless Date.parse

# Final results (with disabled GC):
# 1 – Total time:  18.757046   5.629167  24.386213 ( 26.323017)
# 2 – Total time:  18.611314   3.868813  22.480127 ( 23.585306)
# 3 – Total time:  18.601979   4.001700  22.603679 ( 23.773062)