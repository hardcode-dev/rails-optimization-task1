# frozen_string_literal: true

require_relative "../../lib/services/statistics_service"

describe StatisticsService do
  subject(:service) { described_class.new(data_file_path) }

  describe "#work" do
    let(:data_file_path) { "#{Dir.pwd}/fixtures/data.txt" }
    let(:result_file_path) { "#{Dir.pwd}/tmp/result.json" }

    # rubocop:disable Layout/LineLength
    let(:expected_result) do
      "{\"totalUsers\":3,\"uniqueBrowsersCount\":14,\"totalSessions\":15,\"allBrowsers\":\"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49\",\"usersStats\":{\"Leida Cira\":{\"sessionsCount\":6,\"totalTime\":\"455 min.\",\"longestSession\":\"118 min.\",\"browsers\":\"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39\",\"usedIE\":true,\"alwaysUsedChrome\":false,\"dates\":[\"2017-09-27\",\"2017-03-28\",\"2017-02-27\",\"2016-10-23\",\"2016-09-15\",\"2016-09-01\"]},\"Palmer Katrina\":{\"sessionsCount\":5,\"totalTime\":\"218 min.\",\"longestSession\":\"116 min.\",\"browsers\":\"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17\",\"usedIE\":true,\"alwaysUsedChrome\":false,\"dates\":[\"2017-04-29\",\"2016-12-28\",\"2016-12-20\",\"2016-11-11\",\"2016-10-21\"]},\"Gregory Santos\":{\"sessionsCount\":4,\"totalTime\":\"192 min.\",\"longestSession\":\"85 min.\",\"browsers\":\"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49\",\"usedIE\":false,\"alwaysUsedChrome\":false,\"dates\":[\"2018-09-21\",\"2018-02-02\",\"2017-05-22\",\"2016-11-25\"]}}}\n"
    end
    # rubocop:enable Layout/LineLength

    before do
      File.write(result_file_path, "")
    end

    it "calculates statistics and writes result" do
      service.work

      expect(File.read(result_file_path)).to eq(expected_result)
    end
  end

  describe "complexity" do
    let(:service_1) { described_class.new(data_16_file_path) }
    let(:service_2) { described_class.new(data_8_file_path) }

    let(:data_16_file_path) { "#{Dir.pwd}/fixtures/data_16.txt" }
    let(:data_8_file_path) { "#{Dir.pwd}/fixtures/data_8.txt" }

    it "performs under the linear complexity" do
      expect { service_1.work }.to perform_under(0.8).sec
      expect { service_2.work }.to perform_under(1.6).sec
    end
  end
end
