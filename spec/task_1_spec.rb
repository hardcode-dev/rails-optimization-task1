# frozen_string_literal: true

require 'rspec'
require 'rspec-benchmark'
require_relative '../task_1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

def work_data_5_000
  work('data/data_5_000.txt', disable_gc: false)
end

def work_data_large
  work('data/data_large.txt', disable_gc: true)
end

describe 'Performance' do
  let(:measurement_time_seconds) { 1 }
  let(:warmup_seconds) { 0.4 }

  describe 'work_data_5_000' do
    it 'works under 20.14 ms' do
      expect { work_data_5_000 }.to perform_under(46.14).ms.warmup(1).times.sample(1).times
    end

    # it 'works faster than 1000 ips' do
    #   expect do
    #     work_data_5_000
    #   end.to perform_at_least(1000).within(measurement_time_seconds).warmup(warmup_seconds).ips
    # end
    #
    # it 'performs linear' do
    #   expect { work_data_5_000 }.to perform_linear.in_range(10, 5_000)
    # end
  end

  describe 'work_data_large' do
    it 'works under 30 s' do
      expect { work_data_large }.to perform_under(30).sec.warmup(1).times.sample(1).times
    end
  end
end
