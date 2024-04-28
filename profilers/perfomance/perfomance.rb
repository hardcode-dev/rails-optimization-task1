# frozen_string_literal: true

require 'rspec-benchmark'
require_relative '../../task-1'

describe 'Task-1' do
  include RSpec::Benchmark::Matchers

  # RSpec::Benchmark.configure do |config|
  #   config.disable_gc = true
  # end

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
    let(:file_name) { './data10_000.txt' }

    it 'works under 100 ms' do
      expect do
        WorkV2.work(file_name)
      end.to perform_under(110).ms.warmup(2).times.sample(5).times
    end

    it 'works under 65 ms' do
      expect do
        WorkV3.work(file_name)
      end.to perform_under(65).ms.warmup(2).times.sample(5).times
    end

    it 'works faster' do
      expect { WorkV3.work(file_name) }.to perform_faster_than { WorkV2.work(file_name) }.at_least(1.4).times
    end
  end

  describe 'Performance V4' do
    let(:file_name) { './data30_000.txt' }

    it 'works under 140 ms' do
      expect do
        WorkV4.work(file_name)
      end.to perform_under(140).ms.warmup(2).times.sample(5).times
    end

    it 'works faster' do
      expect { WorkV4.work(file_name) }.to perform_faster_than { WorkV3.work(file_name) }.at_least(1.5).times
    end
  end

  describe 'Performance V5' do
    let(:file_name) { './data30_000.txt' }

    it 'works under 120 ms' do
      expect do
        WorkV5.work(file_name)
      end.to perform_under(120).ms.warmup(2).times.sample(5).times
    end

    it 'works faster' do
      expect { WorkV5.work(file_name) }.to perform_faster_than { WorkV4.work(file_name) }.at_least(1.05).times
    end
  end

  # describe "full data set" do
  #   let(:file_name) { './data_large.txt' }
  #
  #   it 'works under 30 s' do
  #     expect do
  #       WorkV5.work(file_name)
  #     end.to perform_under(30).sec.warmup(2).times
  #   end
  # end

  describe 'full data set' do
    let(:file_name) { './data10_000.txt' }

    it 'works faster' do
      expect { WorkV5.work(file_name) }.to perform_faster_than { InitWork.work(file_name) }.at_least(33).times
    end
  end

  describe 'Complexity' do
    let(:file_names) { %w[data1000.txt data2000.txt data4000.txt data8000.txt data16000.txt] }

    it 'performs perform_power' do
      expect { |_n, i| InitWork.work(file_names[i]) }.to perform_power.in_range(8, 32_768).ratio(8)
      expect { |_n, i| WorkV5.work(file_names[i]) }.to perform_linear
    end
  end
end
