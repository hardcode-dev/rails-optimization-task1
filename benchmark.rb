require_relative 'parser'

Benchmark.bmbm do |x|
  # Asymptotics
  # x.report('1000') { Parser.new(data: 'data/asymptotics/data1000.txt', result: 'data/result.json', disable_gc: false).work }
  # x.report('2000') { Parser.new(data: 'data/asymptotics/data2000.txt', result: 'data/result.json', disable_gc: false).work }
  # x.report('4000') { Parser.new(data: 'data/asymptotics/data4000.txt', result: 'data/result.json', disable_gc: false).work }
  # x.report('8000') { Parser.new(data: 'data/asymptotics/data8000.txt', result: 'data/result.json', disable_gc: false).work }
  # x.report('16000') { Parser.new(data: 'data/asymptotics/data16000.txt', result: 'data/result.json', disable_gc: false).work }

  x.report('Metric_3250') { Parser.new(data: 'data/data3250.txt', result: 'data/result.json', disable_gc: false).work }
end
