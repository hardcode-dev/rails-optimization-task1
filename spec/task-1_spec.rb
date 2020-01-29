require "spec_helper"
require "rspec-benchmark"

require_relative "../task-1"

describe Report do
  include RSpec::Benchmark::Matchers

  context "when data.txt file" do
    let(:file) { file_fixture("data/data.txt") }
    let(:file_path) { file.path }
    let(:file_result) { file.read }
    let(:report) { Report.new(file_path) }
    let(:result_file) { File.open(File.join(ENV["PWD"], "result.json")) }
    let(:result_fixture) { file_fixture("result/data.json").read }

    it "should be valid" do
      report.work

      expect(result_file.read).to eq(result_fixture)
    end
  end

  context "when data_large.txt file", slow: true do
    let(:file) { file_fixture("data/data_large.txt") }
    let(:file_path) { file.path }

    it "should process report less than 30 seconds" do
      expect { described_class.new(file_path).work }.to perform_under(30).sec.warmup(2).times.sample(5).times
    end
  end
end
