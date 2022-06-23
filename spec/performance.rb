require 'rspec-benchmark'
require_relative '../task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  let(:size) { 500_000 }
  let(:file_path) { '../data_large.txt' }
  it 'works under 1 ms' do
    expect {
      work(file_path, false, size)
    }.to perform_under(5_000).ms.warmup(1).sample(2)
  end

  it 'performs linear' do
    expect { |n, _i| work(file_path, false, n) }.to perform_linear.in_range(1_000, 500_000)
  end
end

