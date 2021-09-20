require 'rspec'
require 'rspec-benchmark'

require_relative '../work.rb'

describe 'work performance' do
  include RSpec::Benchmark::Matchers

  it 'performs large data under 30 sec' do
    expect {
      work(filename: 'data_large.txt', disable_gc: false)
    }.to perform_under(30).sec
  end
end
