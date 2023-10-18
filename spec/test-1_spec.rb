# frozen_string_literal: true

require 'rspec-benchmark'
require_relative '../task-1'

RSpec.configure { |config| config.include RSpec::Benchmark::Matchers }

describe 'metrics' do
  it 'performs under certain time' do
    expect { work(filename: 'data32500.txt') }.to perform_under(180).ms.warmup(2).times.sample(10).times
  end

  # плавающий бенчмарк, бесполезно менять threshold и повышать sample, плавает при любых значениях
  it 'performs linear' do
    expect do |n, _i|
      work(filename: "data#{n}.txt")
    end.to perform_linear.in_range(1000, 8000)
  end
end
