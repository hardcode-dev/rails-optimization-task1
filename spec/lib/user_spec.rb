require 'spec_helper'

describe "UserWork" do
  let(:expected_result) {
    File.read("./spec/fixtures/output_data.txt")
  }

  describe ".work" do
    it "return correct data" do
      expect(work("./spec/fixtures/input_data.txt")).to eq(expected_result)
    end

    it "perform time less than 0.001 sec" do
      expect { 
        work("./spec/fixtures/input_data.txt")
      }.to perform_under(0.001).sample(10)
    end

    # it "perform linear" do
    #   files = [
    #     "./spec/fixtures/input_data.txt",
    #     "./spec/fixtures/input_data_small.txt",
    #     "./spec/fixtures/input_data_medium.txt",
    #     "./spec/fixtures/input_data_large.txt",
    #     "./spec/fixtures/input_data_extra_large.txt"
    #   ]

    #   expect { |n, i_|
    #     file_path = files[n]
    #     work(file_path)
    #   }.to perform_linear.in_range(0, 4).sample(25)
    # end
  end
end