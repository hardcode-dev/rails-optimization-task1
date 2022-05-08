require 'rspec-benchmark'
require_relative 'task-1.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

RSpec.describe 'Performance of task-1' do
  let(:filename) { 'data/data_32768.txt' }
  subject { work(filename) }

  it 'works under 250 ms' do
    expect {
      work(filename)
    }.to perform_under(250).ms.warmup(2).times.sample(3).times
  end
end
