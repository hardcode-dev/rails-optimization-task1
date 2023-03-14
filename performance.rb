require 'rspec/core'
require 'rspec-benchmark'
require_relative 'task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'basic work' do
  let(:filepath) { 'data/data_40k.txt' }
  let(:sample) { 10 }

  # start point: 15.48s
  # end point: 0.1s
  it 'works under 0.12 s' do
    expect { work(filepath) }
      .to perform_under(110).ms.warmup(2).times.sample(sample).times
  end
end
