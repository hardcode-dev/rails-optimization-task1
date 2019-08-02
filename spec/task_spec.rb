describe Task do
  subject(:task) do
    described_class.new(result_file_path: result_file_path, data_file_path: data_file_path)
  end

  let(:result_file_path) { 'spec/fixtures/result.json' }
  let(:data_file_path) { 'spec/fixtures/data.txt' }
  let(:expected_result) do
    '{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}' + "\n"
  end
  let(:exepcted_data_from_file) { File.read(result_file_path) }

  after do
    File.delete(result_file_path) if File.exist?(result_file_path)
  end

  describe "#work" do
    it "tests file" do
      task.work
      expect(exepcted_data_from_file).to eq(expected_result)
    end

    describe "performnce test" do
      context "when 20k rows" do
        let(:data_file_path) { 'spec/fixtures/data_20k.txt' }
        # let(:data_file_path) { nil }
        let(:service_work_time) { Benchmark.realtime{ task.work } }

        it 'executes faster than 0.8 seconds' do
          # expect { task.work }.to perform_under(0.85).sec.warmup(2).times.sample(10).times
          # expect { task.work }.to perform_under(0.5)
          expect(service_work_time).to be  < 0.85
        end
      end

      context "when 18 rows" do
        it "executes at least 5_300 times in second" do
          allow(File).to receive(:write).and_return(true)
          expect { task.work }.to perform_at_least(5_300).within(1).warmup(0.2).ips
        end
      end
    end
  end
end
# Изначально
# 1_000 ~ 0.46
# 5_000 ~ 0.72
# 10_000 ~ 3.2
# 20_000 ~ 13.7
# 100_000 ~ 303

# После 1го исправления
# 10_000 ~ 0.335
# 20_000 ~ 1.48

# После второго исправления
# 10_000 ~ 0.315
# 20_000 ~ 1.29

# После третьего исправления
# 10_000 ~ 0.272
# 20_000 ~ 1.11

# После четвёртого исправления
# 10_000 ~ 0.264
# 20_000 ~ 0.920

# После пятого исправления
# 10_000 ~ 0.258
# 20_000 ~ 0.850

# После шестого исправления
# 10_000 ~ 0.218
# 20_000 ~ 0.804

# После седьмого исправления
# 10_000 ~ 0.217
# 20_000 ~ 0.770

# После восьмого исправления
# 10_000 ~ 0.201
# 20_000 ~ 0.750

# После девятого исправления
# 10_000 ~ 0.198
# 20_000 ~ 0.731

# После десятого исправления
# 10_000 ~ 0.187
# 20_000 ~ 0.716
