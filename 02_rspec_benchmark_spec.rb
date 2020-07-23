require 'rspec-benchmark'
require_relative 'task-1'

RSpec.describe "Performance testing" do
  include RSpec::Benchmark::Matchers

  describe 'Performance' do
    before do
      File.write('result.json', '')
      File.write('data.txt', count.times.flat_map do |step|
        [
          "user,#{step},Leida_#{step},Cira,0",
          "session,#{step},#{step},Safari 29,87,2016-10-23"
        ]
      end.join("\n"))
    end

    context 'with 1000 rows' do
      let(:count) { 500 }

      it { expect { work }.to perform_constant }
      it { expect { work }.to perform_under(1).ms.warmup(2).times.sample(10).times }
    end

    context 'with 5000 rows' do
      let(:count) { 2500 }

      it { expect { work }.to perform_constant }
      it { expect { work }.to perform_under(10).ms.warmup(2).times.sample(10).times }
    end

    context 'with 100_000 rows' do
      let(:count) { 50_000 }

      xit { expect { work }.to perform_constant }
      xit { expect { work }.to perform_under(1).sec.warmup(2).times.sample(10).times }
    end
  end
end
