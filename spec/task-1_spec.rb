# frozen_string_literal: true

require 'rspec-benchmark'
require_relative '../task-1'

RSpec.configure { |config| config.include RSpec::Benchmark::Matchers }

`head -n 8000 data/data_large.txt > 'data/data-8000-lines.txt'`

describe 'task_1 performance' do
  let(:file_path) { 'data/data-8000-lines.txt' }

  context 'when the runtime is tested' do
    let(:maximum_execution_time_ms) { 120 }
    let(:warmup) { 1 }
    let(:sample) { 10 }

    it 'works under maximum execution time in ms' do
      expect { work(file_path: file_path)  }
        .to perform_under(maximum_execution_time_ms).ms.warmup(warmup).times.sample(sample).times
    end
  end

  context 'when the ips is tested' do
    let(:mimimum_ips) { 8 }
    let(:measurement_time_seconds) { 0.4 }
    let(:warmup) { 0.2 }

    it 'works faster than mimimum_ips ips' do
      expect { work(file_path: file_path) }
        .to perform_at_least(mimimum_ips).within(measurement_time_seconds).warmup(warmup).ips
    end
  end

  context 'when allocation is tested' do
    let(:maximum_objects_count) { 376_000 }

    xit 'works faster than mimimum_ips ips' do
      expect { work(file_path: file_path, disable_gc: true) }.to perform_allocation(maximum_objects_count)
    end
  end

  context 'when the asymptotics is tested' do
    xit 'works like a power algorithm' do
      # expected block to perform power, but performed power (??)
      expect { work(file_path: file_path) }.to perform_power
    end
  end
end
