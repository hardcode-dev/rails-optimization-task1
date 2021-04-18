require_relative '../task-1'
require 'rspec-benchmark'

FILES = %w[1000.txt 2000.txt 4000.txt 8000.txt].freeze

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

RSpec::Benchmark.configure do |config|
  config.disable_gc = false
end

RSpec.describe 'Performance' do
  it 'data.txt works under 1.2 ms' do
    expect {
      work
    }.to perform_under(1).ms.warmup(2).times.sample(10).times
  end

  it '1000.txt works under 35 ms' do
    expect {
      work('samples/1000.txt')
    }.to perform_under(22).ms.warmup(2).times.sample(10).times
  end

  it '2000.txt works under 70 ms' do
    expect {
      work('samples/2000.txt')
    }.to perform_under(44).ms.warmup(2).times.sample(10).times
  end

  it '4000.txt works under 140 ms' do
    expect {
      work('samples/4000.txt')
    }.to perform_under(88).ms.warmup(2).times.sample(10).times
  end

  it '8000.txt works under 300 ms' do
    expect {
      work('samples/8000.txt')
    }.to perform_under(176).ms.warmup(2).times.sample(10).times
  end

  it 'performs linear' do
    expect { |n, i| work_lines(n, i) }.to perform_linear.in_range(1000, 8000).ratio(2).sample(10).times
  end

  # describe 'data_large.txt' do
  #   it 'works under 30 s' do
  #     expect {
  #       work('data_large.txt')
  #     }.to perform_under(30000).ms.sample(1).times
  #   end
  # end

  def work_lines(num, index)
    puts "Benchmarking #{num} lines, file: #{FILES[index]}..."
    work("./samples/#{FILES[index]}")
  end
end
