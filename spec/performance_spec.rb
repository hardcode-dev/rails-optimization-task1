require_relative '../parser.rb'

describe 'Performance' do
  describe 'parsing' do
    let(:test_data) { 'data/data3250.txt' }
    let(:metric_budget) { 25 }
    let(:data) { 'data/data_large.txt' }
    let(:budget) { 30_000 }
    let(:result) { 'data/result.json' }

    describe 'protect metric' do
      it 'works under _ms' do
        expect { Parser.new(data: test_data, result: result, disable_gc: true).work }
          .to perform_under(metric_budget).ms.warmup(1).times.sample(10).times
      end
    end

    describe 'task_1(parsing large file)' do
      it 'works under 30sec' do
        expect { Parser.new(data: data, result: result, disable_gc: true).work }
          .to perform_under(budget).ms.warmup(1).times.sample(2).times
      end
    end
  end
end
