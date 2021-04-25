require 'rspec-benchmark'

require_relative '../task-1'
#require_relative '../task-old'

RSpec.configure do |config|
    config.include RSpec::Benchmark::Matchers
end

describe 'Perfomance' do
    let(:size) { 100000 }
    it 'works under 20s' do
        expect{
            work("data/data#{size}.txt")
        }.to perform_under(10).sec#.sample(0).times
    end


    it 'perform linear' do
        expect { |n, _i| print("AND NOW WE WORK WITH #{n}"); work("data/data#{n}.txt") }.to perform_linear.in_range([100, 1000, 10000, 100000])
    end
end
