require 'spec_helper'

describe "UserWork" do
  let(:expected_result) {
    File.read("./spec/fixtures/output_data.txt")
  }

  describe ".work" do
    it "return correct data" do
      expect(work("./spec/fixtures/input_data.txt")).to eq(expected_result)
    end

    it "perform " do
      expect { 
        work("./spec/fixtures/input_data.txt") 
      }.to perform_under(0.001).sample(10)
    end
  end
end