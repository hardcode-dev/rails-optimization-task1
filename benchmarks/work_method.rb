require 'benchmark/ips'
require_relative './benchmark_suite.rb'
require_relative '../task-1.rb'

suite = GCSuite.new

# Use helpers/data_generator.rb to generate data
Benchmark.ips do |x|
  x.config(
    stats: :bootstrap,
    confidence: 95,
    suite: suite
  )
  x.report('#work with 1x data') do
    report = Report.new('data/data.txt')
    report.work
  end
  x.report('#work with 2x data') do
    report = Report.new('data/data_2x.txt')
    report.work
  end
  x.report('#work with 4x data') do
    report = Report.new('data/data_4x.txt')
    report.work
  end
  x.report('#work with 8x data') do
    report = Report.new('data/data_8x.txt')
    report.work
  end
  x.report('#work with 16x data') do
    report = Report.new('data/data_16x.txt')
    report.work
  end
  x.report('#work with 32x data') do
    report = Report.new('data/data_32x.txt')
    report.work
  end
  x.report('#work with 64x data') do
    report = Report.new('data/data_64x.txt')
    report.work
  end
  x.report('#work with 128x data') do
    report = Report.new('data/data_128x.txt')
    report.work
  end
  x.report('#work with 256x data') do
    report = Report.new('data/data_256x.txt')
    report.work
  end
  x.report('#work with 512x data') do
    report = Report.new('data/data_512x.txt')
    report.work
  end

  x.compare!
end
