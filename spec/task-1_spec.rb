# frozen_string_literal: true

require 'spec_helper'
require_relative '../task-1.rb'

RSpec.describe 'work efficiency metric', :perf do
  let!(:data_1k_path) { './benchmarking/support/data_1k.txt' }
  let!(:data_2k_path) { './benchmarking/support/data_2k.txt' }
  let!(:data_4k_path) { './benchmarking/support/data_4k.txt' }
  let!(:data_8k_path) { './benchmarking/support/data_8k.txt' }

  it 'matches the timing' do
    expect { work(data_8k_path) }.to perform_under(0.030)
  end

  it 'matches the iterations' do
    expect { work(data_8k_path) }.to perform_at_least(45).ips.within(0.5)
  end

  it 'performs under the linear complexity' do
    expect { work(data_1k_path) }.to perform_under(0.0035)
    expect { work(data_2k_path) }.to perform_under(0.0075)
    expect { work(data_4k_path) }.to perform_under(0.015)
    expect { work(data_8k_path) }.to perform_under(0.030)
  end
end
