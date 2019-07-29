require 'benchmark/ips'

require_relative 'task-1'

# GC.disable
#

MUL = [1, 2, 4, 8, 16].freeze
BASE = 1000

class GCSuite
  def warming(*)
    run_gc
  end

  def running(*)
    run_gc
  end

  def warmup_stats(*)
  end

  def add_report(*)
  end

  private

  def run_gc
    GC.enable
    GC.start
    GC.disable
  end
end

suite = GCSuite.new

Benchmark.ips do |x|
  # The default is :stats => :sd, which doesn't have a configurable confidence
  # confidence is 95% by default, so it can be omitted
  x.config(stats: :bootstrap, confidence: 99, suite: suite)

  MUL.each do |mul|
    number_lines = BASE * mul
    x.report("#{mul}x = #{number_lines}") do
      work('data_large.txt', number_lines)
    end
  end

  x.compare!
end



