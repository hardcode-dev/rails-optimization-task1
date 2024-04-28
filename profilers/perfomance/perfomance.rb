# frozen_string_literal: true

require 'rspec-benchmark'
require_relative '../../task-1'
require_relative '../../task-1-v-1'

describe 'Task-1' do
  include RSpec::Benchmark::Matchers

  RSpec::Benchmark.configure do |config|
    config.disable_gc = true
  end

  describe 'Performance' do
    let(:file_name) { './data4000.txt' }

    it 'works under 550 ms' do
      expect do
        InitWork.work(file_name)
      end.to perform_under(550).ms.warmup(2).times.sample(10).times
    end
  end

  describe 'Performance V1' do
    let(:file_name) { './data4000.txt' }

    it 'works under 100 ms' do
      expect do
        WorkV1.work(file_name)
      end.to perform_under(100).ms.warmup(2).times.sample(10).times
    end

    it 'works under 100 ms' do
      expect { WorkV1.work(file_name) }.to perform_faster_than { InitWork.work(file_name) }.at_least(4).times
    end
  end

  # describe 'Performance' do
  #   let(:file_name) { './data4000.txt' }

  #   it 'works under 550 ms' do
  #   expect { work_v1(file_name) }.to perform_faster_than { work(file_name) }.twice
  #   end
  # end

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
