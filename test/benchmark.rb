require 'benchmark'
require_relative '../lib/worker'

Benchmark.bmbm do |x|
  x.report('1536-rows:') do
    worker = Worker.new("#{__dir__}/../data/data_x1.txt")
    worker.run
  end

  x.report('3072-rows:') do
    worker = Worker.new("#{__dir__}/../data/data_x2.txt")
    worker.run
  end

  x.report('6144-rows:') do
    worker = Worker.new("#{__dir__}/../data/data_x4.txt")
    worker.run
  end
end
