# frozen_string_literal: true

require 'rspec-benchmark'
require_relative '../task-1.rb'

RSpec.configure { |config| config.include RSpec::Benchmark::Matchers }

describe 'Performance' do
  describe 'large data' do
    let(:file) { 'data_large.txt' }

    it 'works under 30 sec' do
      expect { work(file) }.to perform_under(30).sec
    end

    it 'works faster than 1000 ips' do
      expect { work(file) }.to perform_at_least(1000).within(1).ips
    end
  end
end
