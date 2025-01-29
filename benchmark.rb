require 'rspec-benchmark'
require_relative 'task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Task' do
  describe 'execute less 30 sec' do
    let(:file) { 'data_large.txt' }

    it 'success' do
      expect { work(File.read(file)) }.to perform_under(30).sec.sample(3).times
    end
  end

  describe 'linear work' do
    it 'success' do
      expect do
        |n, _i| work(`head -n #{n.to_i} data_large.txt`)
      end.to perform_linear.in_range(100, 3_000_000)
    end
  end
end
