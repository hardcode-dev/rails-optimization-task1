require_relative 'rspec_helper'

describe 'Performance reporter' do
  let(:file_path) { 'fixtures/data200000.txt' }
  let(:time) { 1.5 }
  let(:paths) { ['fixtures/data1000.txt', 'fixtures/data2000.txt', 'fixtures/data4000.txt', 'fixtures/data8000.txt'] }

  shared_examples 'when create report' do
    it 'create report' do
      expect {
        work(file_path)
      }.to perform_under(time).sec.warmup(2).times.sample(10).times
    end  
  end

  it_behaves_like 'when create report'
end
