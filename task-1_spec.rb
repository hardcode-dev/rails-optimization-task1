# frozen_string_literal: true

require 'rspec'
require 'rspec-benchmark'
require_relative 'task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe 'should linear work with small file' do
    let(:filename) { 'data5000.txt' }
    s = 0.02
    it "works under #{s} s" do
      expect do
        work(filename)
      end.to perform_under(s * 1000).ms.warmup(2).times.sample(5).times
    end

    it 'performs linear' do
      expect { work(filename) }.to perform_linear
    end
  end

  describe 'should linear work with medium file' do
    let(:filename) { 'data200_000.txt' }
    s = 1
    it "works under #{s} s" do
      expect do
        work(filename)
      end.to perform_under(s * 1000).ms.warmup(2).times.sample(1).times
    end

    it 'performs linear' do
      expect { work(filename) }.to perform_linear
    end
  end

  # describe 'should linear work with large file' do
  #   let(:filename) { 'data_large.txt' }
  #   s = 30
  #   it "works under #{s} s" do
  #     expect do
  #       work(filename)
  #     end.to perform_under(s * 1000).ms.warmup(1).times.sample(1).times
  #   end
  #
  #   it 'performs linear' do
  #     expect { work(filename) }.to perform_linear
  #   end
  # end
end
