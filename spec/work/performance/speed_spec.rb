RSpec.describe 'Work' do
  describe 'performance' do
    subject { work(file_path) }

    let(:file_path) { fixture(size) }
    let(:warmup_seconds) { 1 }
    let(:size) { 250_000 }
    let(:ms) { 2000 }

    before { ensure_test_data_exists(size) }

    describe 'ms' do
      it 'is equals or better that current implementation' do
        expect { work(file_path) }.to perform_under(ms).ms.warmup(warmup_seconds).times.sample(10).times
      end

      it 'is trying to be better ' do
        expect { work(file_path) }.to perform_under(ms/2).ms.warmup(warmup_seconds).times.sample(10).times
      end
    end
  end
end
