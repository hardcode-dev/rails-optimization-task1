

require 'rspec'
require 'rspec-benchmark'
require_relative 'task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

RSpec.describe 'work' do
  it 'should be linear' do
    `head -n 1000000 data_large.txt > data.txt`

    expect { work }.to perform_linear
  end

  it 'should perform under 15 seconds' do
    `cp data_large.txt data.txt`

    expect { work }.to perform_under(15).sec
  end
end
