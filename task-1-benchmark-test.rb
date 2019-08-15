require 'rspec-benchmark'
require_relative 'codes/report'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

RSpec::Benchmark.configure do |config|
  config.disable_gc = true
end

describe 'task1' do
  it "iterations per second" do
    report = Report.new(:test)
    expect do
      report.run
    end.to perform_at_least(4000).ips
  end
end
