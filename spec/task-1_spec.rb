require 'rspec'
require 'rspec-benchmark'
require_relative '../task-1'

RSpec.describe 'work' do
  include RSpec::Benchmark::Matchers

  it 'should be linear' do
    expect { |number, _|
      `head -n #{number * 1000} data_large.txt > data.txt`

      work
    }.to perform_linear.in_range(1, 100)
  end

  it 'should perform under 5 seconds' do
    `head -n 1000000 data_large.txt > data.txt`

    expect { work }.to perform_under(5).sec
  end

  # it 'should perform under 30 seconds' do
  #   `cp data_large.txt data.txt`

  #   expect { work }.to perform_under(30).sec
  # end
end
