require 'benchmark'
require_relative 'codes/report'

report = Report.new(:benchmark)

time = Benchmark.realtime do
  report.run
end

puts report.save("Finish in #{time.round(3)} sec.")

report.open
