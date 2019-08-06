require 'minitest/benchmark'
require 'minitest/autorun'
require_relative '../task-1'

class BenchTest < MiniTest::Benchmark
  def self.bench_range
    [1000, 2000, 4000, 8000, 16000, 32000, 64000]
  end

  def bench_algorithm
    assert_performance_linear do |n|
      work("data/data_#{n}.txt")
    end
  end
end

