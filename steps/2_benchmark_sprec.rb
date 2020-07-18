require_relative '../task-1'

require 'pry'

require 'rspec'
require 'rspec-benchmark'

RSpec::Benchmark.configure do |config|
  config.disable_gc = true
end

RSpec.describe '#benchmark' do
  include RSpec::Benchmark::Matchers

  context 'parse file' do
    [2500, 5000, 10_000, 20_000].each do |qty_of_row|
      it "data_part_#{qty_of_row}.txt" do
        expect do
          work("data_part_#{qty_of_row}.txt")
        end.to perform_under(0.2).sec.warmup(2).times.sample(10).times
      end
    end

    [50_000, 100_000].each do |qty_of_row|
      it "data_part_#{qty_of_row}.txt" do
        expect do
          work("data_part_#{qty_of_row}.txt")
        end.to perform_under(10).sec.warmup(2).times.sample(10).times
      end
    end
  end

  context 'parse file data_large.txt' do
    it 'is final test' do
      expect do
        work('data_large.txt')
      end.to perform_under(30).sec.warmup(2).times.sample(10).times
    end

    it 'checks linear asymptotics' do
      sizes = [100, 500, 1000, 10_000]
      expect do |n, _i|
        work("data_part_#{n}.txt")
      end.to perform_linear.in_range(sizes)
    end
  end
end
