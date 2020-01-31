require "rspec"
require 'rspec-benchmark'
require_relative 'task-1.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe "BenchmarkSpec" do
  RSpec::Benchmark.configure do |config|
    config.run_in_subprocess = false
    config.disable_gc = false
  end
  it do
    #work("data50.txt")
    expect { work("data50.txt") }.to perform_under(1).sec.warmup(2).times.sample(10).times
  end

  it do
    expect { work("data10000.txt") }.to perform_under(30).sec.warmup(2).times.sample(3).times
  end

  it do
    expect { work("data50000.txt") }.to perform_under(30).sec.warmup(1).times.sample(1).times
  end

  it do
    expect { work("data100000.txt") }.to perform_under(30).sec.warmup(1).times.sample(1).times
  end

  it do
    expect { work("data500000.txt") }.to perform_under(30).sec.warmup(1).times.sample(1).times
  end

  it do
    expect { work("data1500000.txt") }.to perform_under(30).sec.warmup(1).times.sample(1).times
  end

  it do
    expect { work("data_large.txt") }.to perform_under(30).sec.warmup(1).times.sample(1).times
  end
end
