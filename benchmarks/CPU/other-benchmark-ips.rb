require 'benchmark/ips'
require 'set'

Benchmark.ips do |x|
  date = ["2018-09-21","2017-05-22","2018-02-02","2016-11-25"]

  x.report("sort.reverse") do
    date.sort.reverse
  end

  x.report('sort_by') do
    date.sort_by{ |a| a }.reverse
  end

  x.report('rockets') do
    date.sort{ |a,b| b <=> a }
  end

  x.compare!
end
