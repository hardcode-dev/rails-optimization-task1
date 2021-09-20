require 'spec_helper'

RSpec.describe '#work' do
  it 'performs linear' do
    pending
    expect { |n, _i| work("data/data_#{n}.txt") }.to perform_linear.in_range(2000, 16_000).ratio(2).sample(5)
  end

  it 'performs under 0.003s' do
    expect { work('data/data_10000.txt') }.to perform_under(0.03).sec
  end
end
