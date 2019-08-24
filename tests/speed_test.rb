require 'minitest/autorun'
require 'benchmark'
require 'minitest/benchmark'

require_relative '../task-1.rb'

class SpeedTest < Minitest::Benchmark

  def self.bench_range
    [2,4,8]
  end

  def bench_work_method
    assert_performance_linear 0.9 do |n|
      File.write('result.json', '')

      @report = Report.new("data/data_#{2**n}x.txt")
      GC.disable
      @report.work
    end
  end
end
