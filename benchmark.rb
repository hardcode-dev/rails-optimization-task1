require_relative 'task-1'

Benchmark.bm(10) do |x|
  x.report('1 000:')  { work('data/data1000.txt') }
  x.report('2 000:')  { work('data/data2000.txt') }
  x.report('4 000:')  { work('data/data4000.txt') }
  x.report('8 000:')  { work('data/data8000.txt') }
  x.report('16 000:') { work('data/data16000.txt') }
  x.report('32 000:') { work('data/data32000.txt') }
  x.report('64 000:') { work('data/data64000.txt') }
  x.report('128 000:') { work('data/data128000.txt') }
  x.report('256 000:') { work('data/data256000.txt') }
  x.report('512 000:') { work('data/data512000.txt') }
end
