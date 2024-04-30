require_relative '../task-1.rb'

describe "Perfomance" do
  context "it works correctly" do
    let(:sample100_result) { File.join(fixtures_path, 'sample100_result.json') }
    let(:real_result_file)  { File.join(root_path, "result.json") }
    let(:size) { 100 }

    # script to prepare test data
    # it {
    #   prepare_data(size) do |filename|
    #     work(filename)

    #     File.open(sample100_result, 'w') { |file| file.write(File.read(real_result_file)) }
    #   end
    # }

    it {
      prepare_data(size) { |filename| work(filename) }

      expect( File.read(real_result_file) ).to eq(File.read(sample100_result))
    }
  end

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
        }.to perform_under(10).ms.warmup(2).times.sample(10).times
      end
    }
  end

  context "works under 4s for 10000 strings of data" do
    let(:size) { 10_000 }

    it {
      prepare_data(size) do |filename|
        expect {
          work(filename)
        }.to perform_under(100).ms.warmup(2).times.sample(10).times
      end
    }
  end

  context "works under 1s for 100000 strings of data" do
    let(:size) { 100_000 }

    it {
      prepare_data(size) do |filename|
        expect {
          work(filename)
        }.to perform_under(700).ms.warmup(2).times.sample(10).times
      end
    }
  end

  context "works exponential" do
    xit {
      expect { |n, _i|
        prepare_data(n) { |filename| work(filename) }
      }.to perform_linear.in_range(10, 10_000)
    }
  end
end
