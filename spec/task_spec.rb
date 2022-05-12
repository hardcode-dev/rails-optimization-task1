# frozen_string_literal: true

require 'rspec-benchmark'
require_relative '../task_1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe '#work_new' do
    it 'works under 30 sec' do
      expect { work_new }.to perform_under(30).sec.warmup(2).times.sample(10).times
    end
  end
end

describe 'Quality' do
  it 'process data.txt correctly' do
    work_new('data_storage/data.txt')
    result = '{":total_users":3,":total_sessions":15,":unique_browsers_count":14,":users_stats":{"Leida Cira":{":sessions_count":6,":total_time":"455 min.",":longest_session":"118 min.",":browsers":"Safari 29, Firefox 12, Internet Explorer 28, Internet Explorer 28, Safari 39, Internet Explorer 35",":used_ie":true,":always_used_chrome":false,":dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{":sessions_count":5,":total_time":"218 min.",":longest_session":"116 min.",":browsers":"Safari 17, Firefox 32, Chrome 6, Internet Explorer 10, Chrome 13",":used_ie":true,":always_used_chrome":false,":dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{":sessions_count":4,":total_time":"192 min.",":longest_session":"85 min.",":browsers":"Chrome 35, Safari 49, Firefox 47, Chrome 20",":used_ie":false,":always_used_chrome":false,":dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}},":all_browsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49"}' + "\n"
    expect(File.read('result_new.json')).to eq result
  end
end
