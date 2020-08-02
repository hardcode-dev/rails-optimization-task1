# frozen_string_literal: true

require 'rspec-benchmark'
require_relative '../task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  context 'with 20k string perform under 65 ms' do
    it { expect { work('files/data-20k') }.to perform_under(65).ms.warmup(2).times.sample(10).times }
  end

  context 'with 100k string perform under 550 ms' do
    it { expect { work('files/data-100k') }.to perform_under(550).ms.warmup(2).times.sample(10).times }
  end

  context 'with 300k string(~10%) perform under 2.2 sec' do
    it { expect { work('files/data-300k') }.to perform_under(2.2).sec.warmup(2).times.sample(10).times }
  end

  context 'with 1M string(~30%) perform under 9 sec' do
    it { expect { work('files/data-1m') }.to perform_under(9).sec.warmup(2).times.sample(10).times }
  end

  context 'with ~3M string(100%) perform under 38 sec' do
    it { expect { work('files/data_large') }.to perform_under(38).sec.warmup(2).times.sample(10).times }
  end
end
