require_relative '../task-1.rb'

describe "Perfomance" do
  it "works under 3ms for 100 strings of data" do
    expect {
      work('spec/fixtures/sample100.txt')
    }.to perform_under(3).ms.warmup(2).times.sample(10).times
  end

  it "works under 0.05s for 1000 strings of data" do
    expect {
      work('spec/fixtures/sample1000.txt')
    }.to perform_under(50).ms.warmup(2).times.sample(10).times
  end

  xit "works under 4s for 10000 strings of data" do
    expect {
      work('spec/fixtures/sample10000.txt')
    }.to perform_under(4).sec.warmup(2).times.sample(3).times
  end
end
