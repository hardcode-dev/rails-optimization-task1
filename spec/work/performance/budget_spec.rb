RSpec.describe 'Work' do
  describe 'performance' do
    subject { work(file_path) }

    let(:file_path) { fixture(size) }
    let(:warmup_seconds) { 1 }
    let(:size) { 10_000 }
    let(:ms) { 2_800 }

    before { ensure_test_data_exists(size) }

    xdescribe 'budget' do
      let(:file_path) { 'data_large.txt' }

      it 'is fast as hell' do
        expect { work(file_path) }.to perform_under(30).sec.warmup(warmup_seconds).times.sample(2).times
      end
    end
  end
end
