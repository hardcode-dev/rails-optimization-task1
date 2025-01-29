# frozen_string_literal: true

require 'rspec'
require 'rspec-benchmark'
require_relative '../task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

RSpec.describe 'WorkPerformance' do
  describe '.work' do
    context 'when file contains 25 thousands lines' do
      it 'performs under 1 second' do
        expect { work(file_name: 'data_25000_thousands_lines.txt') }.to perform_under(1).sec
      end
    end

    context 'when file contains 150 thousands lines' do
      it 'performs under 3 seconds' do
        expect { work(file_name: 'data_150_thousands_lines.txt') }.to perform_under(3).sec
      end
    end

    context 'when file contains 500 thousands lines' do
      it 'performs under 5 seconds' do
        expect { work(file_name: 'data_500_thousands_lines.txt') }.to perform_under(5).sec
      end
    end

    context 'when file contains 3_250_940 lines' do
      it 'performs under 30 seconds' do
        expect { work(file_name: 'data_large.txt') }.to perform_under(30).sec
      end
    end
  end
end
