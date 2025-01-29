require_relative 'rspec_helper'

describe 'Performance reporter' do
  let(:file_path) { 'fixtures/data200000.txt' }
  let(:time) { 1 }
  
  it 'create report' do
    expect {
      work(file_path)
    }.to perform_under(time).sec.warmup(2).times.sample(10).times
  end  
end
