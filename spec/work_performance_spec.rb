require_relative 'spec_helper'
require_relative '../work'

RSpec.describe "Work performance testing" do
  let(:work) { Work.new(file: 'data_large.txt') }

  it 'executes in less than 30 seconds' do
    expect { work.perform }.to perform_under(30).sec.warmup(1).times.sample(2).times
  end
end
