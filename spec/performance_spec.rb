require 'rspec-benchmark'
require_relative '../work_method'

RSpec.describe "Performance testing" do
  include RSpec::Benchmark::Matchers

  it { expect { work('data_large.txt', 16000) }.to perform_under(500).ms }
end