RSpec.describe 'Work' do
  describe 'performance' do
    let(:from) { 8 }
    let(:to) { 100_000 }
    let(:benchmark_range) { bench_range(from, to) }
    let(:file_path) { full_path("spec/fixtures/data#{size}.txt") }

    describe 'complexity' do
      before { benchmark_range.each { |i| ensure_test_data_exists(i) } }

      it 'is linear' do
        expect { |n, _i| work(fixture(n)) }.to perform_linear.in_range(from, to)
      end

      # it 'is logarithmic' do
      #   expect { |n, _i| work(fixture(n)) }.to perform_logarithmic.in_range(from, to)
      # end

      # it 'is not power' do
      #   expect { |n, _i| work(fixture(n)) }.not_to perform_power.in_range(from, to)
      # end
    end
  end
end
