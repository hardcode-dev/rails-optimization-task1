# frozen_string_literal: true

require 'rspec-benchmark'
require_relative '../task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  context 'with 20k string perform under 150 ms' do
    let(:file_path) { 'files/data-20k' }

    it { expect { work(file_path) }.to perform_under(150).ms.warmup(2).times.sample(10).times }
  end

  context 'with 100k string perform under 880 ms' do
    let(:file_path) { 'files/data-100k' }

    it { expect { work(file_path) }.to perform_under(880).ms.warmup(2).times.sample(10).times }
  end

  context 'with 300k string(~10%) perform under 3.1 sec' do
    let(:file_path) { 'files/data-300k' }

    it { expect { work(file_path) }.to perform_under(3.1).sec.warmup(2).times.sample(10).times }
  end
end
