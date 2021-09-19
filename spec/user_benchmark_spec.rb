require 'spec_helper'

RSpec.describe '#work' do

  it 'performs linear' do
    pending
    expect { work('data_10000.txt') }.to perform_linear
  end

  it 'performs under 0.2s' do
    expect { work('data_10000.txt') }.to perform_under(0.15).sec
  end

end
