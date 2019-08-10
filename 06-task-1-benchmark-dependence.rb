require 'minitest/autorun'
require 'minitest/benchmark'
require './01-task-1.rb'
require './02-task-1-refactored.rb'

GC.disable

class BenchTest < MiniTest::Benchmark
  def self.bench_range
    [1000, 10000, 20000, 40000, 80000, 160000]
  end

  def bench_algorithm
    assert_performance_linear do |n|
      Refactored.new.work("bench_data/data_bench_#{n}.txt")
    end
  end
end