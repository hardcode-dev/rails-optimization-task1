require 'benchmark/ips'
require 'smarter_csv'

Benchmark.ips do |x|
  x.report("SmarterCSV") do
    SmarterCSV.process('../data.txt')
  end

  x.report('File') do
    File.read('../data.txt')
  end

  x.compare!
end
