require 'benchmark'
require 'minitest/autorun'
require 'minitest/benchmark'
require_relative '../lib/parser'

class ParserBench < Minitest::Benchmark
  def self.bench_range
    [1, 2, 4, 8, 16]
  end

  def setup
    test_data = File.read('test/test_data.txt')
    self.class.bench_range.each do |n|
      data = test_data * n
      File.write("test/test_data_x#{n}.txt", data)
    end
  end

  def teardown
    self.class.bench_range.each do |n|
      File.delete("test/test_data_x#{n}.txt")
    end
  end

  def bench_work_asymp
    assert_performance_exponential(0.8) do |n|
      Parser.new(file_path: "test/test_data_x#{n}.txt").work
    end
  end

  def bench_work_time
    time = Benchmark.realtime {
      Parser.new(file_path: 'test/100000.txt').work
    }
    assert_operator 2, :>, time.real
  end
end
