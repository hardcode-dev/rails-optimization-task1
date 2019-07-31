require 'multi_json'
require 'minitest/autorun'

def user_stats(sessions)
  sessions_time    = []
  sessions_browser = []
  sessions_date    = []
  sessions.each do |s|
    sessions_time    << s[:time]
    sessions_browser << s[:browser]
    sessions_date    << s[:date]
  end
  {
      sessionsCount:    sessions.count,
      totalTime:        "#{sessions_time.sum} min.",
      longestSession:   "#{sessions_time.max} min.",
      browsers:         sessions_browser.sort.join(', '),
      usedIE:           sessions_browser.any? { |b| b[0] == 'I' },
      alwaysUsedChrome: sessions_browser.all? { |b| b[0] == 'C' },
      dates:            sessions_date.sort.reverse
  }
end

def work(file_name, gc = true)
  gc ? GC.enable : GC.disable
  time           = Time.now
  users_count    = 0
  browsers       = []
  total_sessions = 0
  users_stats    = {}
  File.read(file_name).split('user,')[1..].each do |raw_line|
    user_sessions = raw_line.split("\n")
    user = user_sessions[0].split(',')
    sessions = user_sessions[1..].map do |raw|
      session = raw.split(',')
      total_sessions += 1
      browser = session[3].upcase
      browsers << browser # unless browsers.include?(browser)
      { browser: browser, time: session[4].to_i, date: session[5] }
    end
    user_name = "#{user[1]} #{user[2]}"
    users_stats[user_name] = user_stats(sessions)
    users_count += 1
  end
  uniq_browsers = browsers.uniq
  report = { totalUsers:          users_count,
             uniqueBrowsersCount: uniq_browsers.count,
             totalSessions:       total_sessions,
             allBrowsers:         uniq_browsers.sort.join(','),
             usersStats:          users_stats }
  File.write('result.json', "#{MultiJson.dump(report)}\n")
  puts "===== #{file_name} ===== GC: #{gc ? 'enabled' : 'disabled' } TIME: #{Time.now - time}" # ===== data_large.txt ===== GC: disabled TIME: # 11.703119
end

# work('data_test.txt', false)
# work('data_small.txt', false)
work('data_large.txt', false)

class TestMe < Minitest::Test
  def setup
    File.write('result.json', '')
    File.write('data_test.txt',
'user,0,Leida,Cira,0
session,0,0,Safari 29,87,2016-10-23
session,0,1,Firefox 12,118,2017-02-27
session,0,2,Internet Explorer 28,31,2017-03-28
session,0,3,Internet Explorer 28,109,2016-09-15
session,0,4,Safari 39,104,2017-09-27
session,0,5,Internet Explorer 35,6,2016-09-01
user,1,Palmer,Katrina,65
session,1,0,Safari 17,12,2016-10-21
session,1,1,Firefox 32,3,2016-12-20
session,1,2,Chrome 6,59,2016-11-11
session,1,3,Internet Explorer 10,28,2017-04-29
session,1,4,Chrome 13,116,2016-12-28
user,2,Gregory,Santos,86
session,2,0,Chrome 35,6,2018-09-21
session,2,1,Safari 49,85,2017-05-22
session,2,2,Firefox 47,17,2018-02-02
session,2,3,Chrome 20,84,2016-11-25
')
  end

  def test_result
    work('data_test.txt', false)
    expected_result = '{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}' + "\n"
    assert_equal expected_result, File.read('result.json')
  end
end
