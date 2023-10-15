RSpec.shared_examples 'speed' do
  # let(:ms) { 40 }
  # let(:size) { 1000 }
  # let(:ips) { 25 }

  subject { described_class.work(file_path) }

  let(:file_path) { fixture(size) }
  let(:warmup_seconds) { 1 }

  before { ensure_test_data_exists(size) }

  describe 'ms' do
    it { expect { subject }.to perform_under(ms).ms.warmup(warmup_seconds).times.sample(10).times }
  end

  describe 'ips' do
    let(:measurement_time_seconds) { 1 }

    it 'works faster than 2 ips' do
      expect { subject }.to perform_at_least(ips).within(measurement_time_seconds).warmup(warmup_seconds).ips
    end
  end
end
