require_relative '../../task-1'

RSpec.describe('Benchmark of work method') do
  describe 'Performance' do
    it 'works quickly' do
      expect { work(file_name: 'spec/fixtures/data_sample_50000.txt') }.to perform_under(400).ms.warmup(2).times.sample(10).times
    end
  end

  describe 'Complexity' do
    it 'has linear complexity' do
      expect do |n, _index|
        work(file_name: "spec/fixtures/data_sample_#{n}.txt")
      end.to perform_linear.in_range([10_000, 20_000, 30_000, 40_000, 50_000]).threshold(0.1)
    end
  end
end
