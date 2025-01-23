require 'benchmark/ips'
require_relative '../../lib/task-1'
require_relative '../utils/artifact_cleaner'

gb_disable = ARGV[0]

config = { stats: :bootstrap, confidence: 95}



Benchmark.ips do |x|
  
  x.config(**config)

  x.report('1000 rows') do
    work('fixtures/data1000.txt', gb_disable)
  end

  x.report('2000 rows') do
    work('fixtures/data2000.txt', gb_disable)
  end

  x.report('4000 rows') do
    work('fixtures/data4000.txt', gb_disable)
  end

  x.report('8000 rows') do
    work('fixtures/data8000.txt', gb_disable)
  end
end

ArtifactCleaner.clean('result.json')