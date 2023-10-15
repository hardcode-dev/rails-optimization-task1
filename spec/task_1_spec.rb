require 'rspec-benchmark'
require_relative '../task-1'

RSpec.describe Work do
  include_examples 'works'

  describe 'performance' do
    let(:from) { 8 }
    let(:to) { 10_000 }
    let(:benchmark_range) { bench_range(from, to) }
    let(:file_path) { full_path("spec/fixtures/data#{size}.txt") }

    xdescribe 'complexity' do
      before {benchmark_range.each { |i| ensure_test_data_exists(i) }}

      it 'performs linear' do
        expect { |n, _i| described_class.work(fixture(n)) }.to perform_linear.in_range(from, to)
      end

      it 'performs logarithmic' do
        expect { |n, _i| described_class.work(fixture(n)) }.to perform_logarithmic.in_range(from, to)
      end

      it 'performs power' do
        expect { |n, _i| described_class.work(fixture(n)) }.to perform_power.in_range(from, to)
      end
    end

    describe 'speed' do
      include_examples 'speed' do
        let(:size) { 1000 }
        let(:ms) { 40 }
        let(:ips) { 25 }
      end
    end
  end
end
