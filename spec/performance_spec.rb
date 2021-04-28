require_relative '../parser.rb'

describe 'Performance' do
  describe 'parsing' do
    # let(:data) { 'data/data_large.txt' }
    let(:data) { 'data/data3250.txt' }
    let(:result) { 'data/result.json' }
    # let(:budget) { 30_000 }
    let(:budget) { 25 }

    # it 'works under 30_000 ms' do
    it 'works under _ms' do
      expect { Parser.new(data: data, result: result, disable_gc: true).work }
        .to perform_under(budget).ms.warmup(2).times.sample(10).times
    end
  end
end
