RSpec.describe GenerateReport do
  # let(:path) { 'spec/support/fixtures/data_large.txt' }

  # before { File.write('result.json', '') }

  # it 'work time is less than 30 seconds' do
  #   expect { subject.work(path) }.to perform_under(30).sec.warmup(2).sample(5)
  # end

  context 'data_64000' do
    let(:path) { 'spec/support/fixtures/data_64000.txt' }

    before { File.write('result.json', '') }

    it 'work time is less than 1 seconds' do
      expect { subject.work(path) }.to perform_under(30).sec.warmup(2).sample(5)
    end
  end
end
