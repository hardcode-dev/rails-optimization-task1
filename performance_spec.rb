require 'rspec-benchmark'
require_relative 'task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end
 
describe 'Performance' do
  let(:input) { 'data_large.txt' }
  let(:output) { 'result.json' }

  it 'works under 3 sec for 500_000 rows' do
    expect {
      work(input, output, rows_count: 500_000)
    }.to perform_under(3).sec.warmup(2).sample(2)
  end

  it 'performs linear' do
    expect { |n, _i| work(input, output, rows_count: n) }.to perform_linear.in_range(1_000, 500_000)
  end
end
