# frozen_string_literal: true

require 'rspec-benchmark'
require_relative '../../task-1'

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

    it 'works under 110 ms' do
      expect do
        WorkV1.work(file_name)
      end.to perform_under(110).ms.warmup(2).times.sample(10).times
    end

    it 'works 4 times faster' do
      expect { WorkV1.work(file_name) }.to perform_faster_than { InitWork.work(file_name) }.at_least(4).times
    end
  end

  describe 'Performance V2' do
    let(:file_name) { './data4000.txt' }

    it 'works under 85 ms' do
      expect do
        WorkV2.work(file_name)
      end.to perform_under(85).ms.warmup(2).times.sample(10).times
    end

    it 'works 10 % faster' do
      expect { WorkV2.work(file_name) }.to perform_faster_than { WorkV1.work(file_name) }.at_least(1.1).times
    end
  end

  describe 'Performance V3' do
    let(:file_name) { './data30_000.txt' }

    it 'works under 1 s' do
      expect do
        WorkV2.work(file_name)
      end.to perform_under(1).sec.warmup(2).times.sample(5).times
    end

    it 'works under 0.5 s' do
      expect do
        WorkV3.work(file_name)
      end.to perform_under(0.5).sec.warmup(2).times.sample(5).times
    end

    it 'works almost twice faster' do
      expect { WorkV3.work(file_name) }.to perform_faster_than { WorkV2.work(file_name) }.at_least(1.9).times
    end
  end

  describe 'Performance V4' do
    let(:file_name) { './data30_000.txt' }

    it 'works under 240 ms' do
      expect do
        WorkV4.work(file_name)
      end.to perform_under(260).ms.warmup(2).times.sample(5).times
    end

    it 'works almost twice faster' do
      expect { WorkV4.work(file_name) }.to perform_faster_than { WorkV3.work(file_name) }.at_least(1.9).times
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
