require_relative 'task-1'

Benchmark.bm(10) do |x|
  x.report('128 000:') { work('data/data128000.txt') }
  x.report('256 000:') { work('data/data256000.txt') }
  x.report('512 000:') { work('data/data512000.txt') }
  x.report('1 024 000:') { work('data/data1024000.txt') }
  x.report('full:') { work('data_large.txt') }
end
