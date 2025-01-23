require 'benchmark'
require_relative '../../lib/task-1'
require_relative '../utils/artifact_cleaner'

gb_disable = ARGV[0]


time_1000rows = Benchmark.realtime do
  work('fixtures/data1000.txt', gb_disable)
end

time_2000rows = Benchmark.realtime do
  work('fixtures/data2000.txt', gb_disable)
end

time_4000rows = Benchmark.realtime do
  work('fixtures/data4000.txt', gb_disable)
end

time_8000rows = Benchmark.realtime do
  work('fixtures/data8000.txt', gb_disable)
end

time_100000rows = Benchmark.realtime do
  work('fixtures/data100000.txt', gb_disable)
end

time_200000rows = Benchmark.realtime do
  work('fixtures/data200000.txt', gb_disable)
end

time_large = Benchmark.realtime do
  work('fixtures/data_large.txt', gb_disable)
end

def printer(time, rows = 1000)
  pp "Processing time from file #{rows} rows: #{time.round(4)}" 
end

printer(time_1000rows)
printer(time_2000rows, 2000)
printer(time_4000rows, 4000)
printer(time_8000rows, 8000)
printer(time_100000rows, 100_000)
printer(time_200000rows, 200_000)
printer(time_large, 1_000_000)

ArtifactCleaner.clean('result.json')