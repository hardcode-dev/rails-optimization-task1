require './work'
require 'rspec-benchmark'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe '#work' do
  context 'with 5000-rows file' do
    it 'works under 70 ms' do
      expect {
        work "test/data/data_5000.txt"
      }.to perform_under(0.07).sec.warmup(2).times.sample(10).times
    end
  end

  it 'has linear asymptotics' do
    sizes = [1000, 2000, 4000, 8000]
    expect do |n, _i|
      file = "test/data/data_#{n}.txt"
      work(file)
    end.to perform_linear.in_range(sizes).sample(10).times
  end
end
