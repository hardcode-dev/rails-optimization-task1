require 'rspec-benchmark'
require 'rspec'

require_relative 'work_method.rb'

describe "Performance" do
  include RSpec::Benchmark::Matchers
  it "works under 100s" do
    expect { work("data_large.txt") }.to perform_under(100000).ms.warmup(2).times.sample(5).times
  end
end
