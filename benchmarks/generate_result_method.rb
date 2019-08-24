require 'benchmark/ips'
require_relative './benchmark_suite.rb'
require_relative '../task-1.rb'
require 'oj'

report = Report.new('data/data_512x.txt')
report.work

suite = GCSuite.new

Benchmark.ips do |x|
  x.config(
    stats: :bootstrap,
    confidence: 95,
    suite: suite
  )
  x.report('#generate_result slow') do
    File.write('result.json', "#{report.summary.to_json}\n")
  end
  x.report('#generate_result fast') do
    File.write('result.json', "#{Oj.dump(report.summary)}\n")
  end

  x.compare!
end
