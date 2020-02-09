# Optimized version of homework task

require 'oj'
require 'minitest'
require 'set'

def set_default_user_stats
  @user_time = []
  @dates = []
  @user_sessions = 0
  @user_browsers = []
  @used_ie = false
  @always_used_chrome = true
end

def set_default_user_stats_report(report, user_name)
  report['usersStats'][user_name] ||= {}
  report['usersStats'][user_name] = {
    'sessionsCount' => 0,
    'totalTime' => '',
    'longestSession' => '',
    'browsers' => [],
    'usedIE' => false,
    'alwaysUsedChrome' => true,
    'dates' => []
  }
end

def generate_user_stats(report, user_name)
  report['usersStats'][user_name]['sessionsCount'] = @user_sessions
  report['usersStats'][user_name]['totalTime'] = "#{@user_time.sum} min."
  report['usersStats'][user_name]['longestSession'] = "#{@user_time.max} min."
  report['usersStats'][user_name]['browsers'] = @user_browsers.sort.join(', ')
  report['usersStats'][user_name]['usedIE'] = @used_ie
  report['usersStats'][user_name]['alwaysUsedChrome'] = @always_used_chrome
  report['usersStats'][user_name]['dates'] = @dates.sort.reverse
end

def work
  report = {
    'totalUsers' => 0,
    'uniqueBrowsersCount' => 0,
    'totalSessions' => 0,
    'allBrowsers' => '',
    'usersStats' => {}
  }

  users_count = 0
  uniq_browsers = SortedSet.new
  total_sessions = 0

  user_id = ''
  user_name = ''

  set_default_user_stats

  amount_of_lines = File.read('data_sample.txt').each_line.count

  File.read('data_sample.txt').split("\n").each_with_index do |line, index|
    cols = line.split(',')

    if cols[0] == 'session' && user_id == cols[1]
      browser = cols[3].upcase
      total_sessions += 1
      uniq_browsers << browser
      @user_time << cols[4].to_i
      @user_sessions += 1
      @user_browsers << browser
      @used_ie = true if browser.start_with?('INTERNET EXPLORER')
      @always_used_chrome = false unless browser.start_with?('CHROME')
      @dates << cols[5]
      next unless amount_of_lines == index + 1
    end

    if @user_sessions > 0
      generate_user_stats(report, user_name)
      set_default_user_stats
    end

    next unless cols[0] == 'user'

    user_id = cols[1]
    user_name = "#{cols[2]} #{cols[3]}"
    users_count += 1

    generate_user_stats(report, user_name)
  end

  report['totalUsers'] = users_count
  report['uniqueBrowsersCount'] = uniq_browsers.length
  report['totalSessions'] = total_sessions
  report['allBrowsers'] = uniq_browsers.to_a.join(',')

  File.write("result.json", Oj.dump(report) + "\n")
end

class TestMe < Minitest::Test
  def setup
    File.write('result.json', '')
    File.write('data.txt',
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
    work
    expected_result = '{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}' + "\n"
    assert_equal expected_result, File.read('result.json')
  end
end

work
