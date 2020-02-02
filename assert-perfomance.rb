require 'rspec-benchmark'
require_relative 'task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Perfomance' do
  describe 'linear work' do
    it 'works' do
      expect { work }.to perform_under(8000).ms.warmup(2)
    end

    # it 'performs linear' do
    #   expect { |n, _i| work}.to perform_linear.in_range(10, 10_000)
    # end
  end
end
