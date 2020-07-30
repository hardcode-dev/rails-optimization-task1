# frozen_string_literal: true

require 'rspec-benchmark'
require_relative '../task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  context 'with 1k string perform under 40 ms' do
    let(:file_path) { 'files/data-1k' }

    it { expect { work(file_path) }.to perform_under(40).ms.warmup(2).times.sample(5).times }
  end

  context 'with 10k string perform under 1.8 sec' do
    let(:file_path) { 'files/data-10k' }

    it { expect { work(file_path) }.to perform_under(1.8).sec.warmup(2).times.sample(5).times }
  end

  context 'with 20k string perform under 10 sec' do
    let(:file_path) { 'files/data-20k' }

    it { expect { work(file_path) }.to perform_under(10).sec.warmup(2).times.sample(5).times }
  end
end
