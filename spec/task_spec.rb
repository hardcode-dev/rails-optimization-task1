# frozen_string_literal: true

require 'rspec-benchmark'
require_relative '../task-1'

RSpec.describe 'Task №1' do
  include RSpec::Benchmark::Matchers

  describe '#work' do
    let(:data) { File.read('spec/fixtures/data.txt') }
    let(:result_data) { File.read('spec/fixtures/result.json') }

    context 'health check' do
      before do
        File.write('result.json', '')
        File.write('data.txt', data)
      end

      after do
        File.delete('result.json')
        File.delete('data.txt')
      end

      it 'returns users data(in json)' do
        work
        expect(File.read('result.json')).to eq(result_data)
      end
    end
  end
end
