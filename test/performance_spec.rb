require 'rspec-benchmark'
require_relative '../lib/worker'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe 'linear work' do
    let (:file_path) { "#{__dir__}/../data/data_x2.txt" }
    it '3072 rows works under 25ms' do
      expect {
        worker = Worker.new(file_path)
        worker.run
      }.to perform_under(0.025).sec.warmup(2).times.sample(10).times
    end

    it 'has linear asymptotics' do
      expect do |n, _i|
        worker = Worker.new("#{__dir__}/../data/data_x#{n}.txt")
        worker.run
      end.to perform_linear.in_range([1, 2, 4]).sample(10).times
    end
  end
end
