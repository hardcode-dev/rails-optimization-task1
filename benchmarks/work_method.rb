require 'benchmark/ips'
require_relative '../task-1.rb'

Benchmark.ips do |x|
  x.config(
    stats: :bootstrap,
    confidence: 95
  )
  x.report('#work with 1x data') do
    work(filename: 'data/data.txt', disable_gc: true)
  end
  x.report('#work with 2x data') do
    work(filename: 'data/data_2x.txt', disable_gc: true)
  end
  x.report('#work with 4x data') do
    work(filename: 'data/data_4x.txt', disable_gc: true)
  end
  x.report('#work with 8x data') do
    work(filename: 'data/data_8x.txt', disable_gc: true)
  end
  x.report('#work with 16x data') do
    work(filename: 'data/data_16x.txt', disable_gc: true)
  end
  x.report('#work with 32x data') do
    work(filename: 'data/data_32x.txt', disable_gc: true)
  end
  x.report('#work with 64x data') do
    work(filename: 'data/data_64x.txt', disable_gc: true)
  end
  x.report('#work with 128x data') do
    work(filename: 'data/data_128x.txt', disable_gc: true)
  end
  x.report('#work with 256x data') do
    work(filename: 'data/data_256x.txt', disable_gc: true)
  end
  x.report('#work with 512x data') do
    work(filename: 'data/data_512x.txt', disable_gc: true)
  end

  x.compare!
end
