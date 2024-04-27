# frozen_string_literal: true

require 'rspec-benchmark'
require_relative '../../task-1'

describe 'Task-1' do
  include RSpec::Benchmark::Matchers

  RSpec::Benchmark.configure do |config|
    config.disable_gc = true
  end

  let(:process) { work(file_name) }

  describe 'Performance' do
    let(:file_name) { './data10_000.txt' }

    it 'works under 6000 ns' do
      expect do
        process
      end.to perform_under(6000).ns.warmup(1).times.sample(10).times
    end
  end

  #   describe 'Complexity' do
  #     let (:file_names) { ['data1000.txt', 'data2000.txt', 'data3000.txt', 'data4000.txt'] }

  #     it 'performs power' do
  #       expect { |n, i| work(file_names[i]) }.to perform_linear.in_range(8, 4096)
  #     end

  #     # it 'peforms slower than linear' do
  #     #   expect { quadratic_work(size) }.to perform_slower_than { linear_work(size) }
  #     # end
  #   end
end
