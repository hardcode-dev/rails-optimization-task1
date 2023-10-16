# frozen_string_literal: true

require 'benchmark/ips'
require_relative '../task-1'

FILES = {
  '1Mb' => 1_048_576,
  '2Mb' => 2_097_152,
  '3Mb' => 3_145_728,
  '4Mb' => 4_194_304,
  '5Mb' => 5_242_880
}.freeze

# GCSuite
class GCSuite
  def warming(*)
    run_gc
  end

  def running(*)
    run_gc
  end

  def warmup_stats(*); end

  def add_report(*); end

  private

  def run_gc
    GC.enable
    GC.start
    GC.disable
  end
end

suite = GCSuite.new

Benchmark.ips do |x|
  x.config(suite: suite, stats: :bootstrap, confidence: 99)
  FILES.each_key do |size|
    x.report("File: #{size}") { work(input_filename: "./profiling/files/data_#{size}", output_filename: '/dev/null') }
  end
  x.compare!
end
