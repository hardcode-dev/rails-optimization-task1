require_relative '../task-1.rb'

describe "Perfomance" do

  context "works under 3ms for 100 strings of data" do
    let(:size) { 100 }

    it {
      prepare_data(size) do |filename|
        expect {
          work(filename)
        }.to perform_under(3).ms.warmup(2).times.sample(10).times
      end
    }
  end

  context "works under 0.05s for 1000 strings of data" do
    let(:size) { 1000 }

    it {
      prepare_data(size) do |filename|
        expect {
          work(filename)
        }.to perform_under(50).ms.warmup(2).times.sample(10).times
      end
    }
  end

  xit "works under 4s for 10000 strings of data" do
    expect {
      work('spec/fixtures/sample10000.txt')
    }.to perform_under(4).sec.warmup(2).times.sample(3).times
  end

  context "works exponential" do
    it {
      expect { |n, _i|
        prepare_data(n) { |filename| work(filename) }
      }.to perform_exponential.in_range(10, 10_000)
    }
  end
end
