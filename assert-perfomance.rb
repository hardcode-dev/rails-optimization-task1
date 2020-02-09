require 'rspec-benchmark'
require_relative 'task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Perfomance' do
  describe 'linear work' do
    it 'works' do
      expect { work }.to perform_under(1000).ms.warmup(2)
    end
  end
end
