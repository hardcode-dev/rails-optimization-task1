require 'pry'
require 'minitest/autorun'
require_relative '../helpers/sessions.rb'
require_relative '../task-1.rb'

class TaskOneTest < Minitest::Test

  def setup
    File.write('result.json', '')
  end

  def test_get_user_sessions
    sessions = get_user_sessions(sessions_test_data, {"id"=>"1"})
    expected_result = [{"user_id"=>"1", "session_id"=>"0", "browser"=>"Safari 17", "time"=>"12", "date"=>"2016-10-21"}, {"user_id"=>"1", "session_id"=>"1", "browser"=>"Firefox 32", "time"=>"3", "date"=>"2016-12-20"}, {"user_id"=>"1", "session_id"=>"2", "browser"=>"Chrome 6", "time"=>"59", "date"=>"2016-11-11"}, {"user_id"=>"1", "session_id"=>"3", "browser"=>"Internet Explorer 10", "time"=>"28", "date"=>"2017-04-29"}, {"user_id"=>"1", "session_id"=>"4", "browser"=>"Chrome 13", "time"=>"116", "date"=>"2016-12-28"}]
    assert_equal expected_result, sessions
  end

  def test_result
    work(filename: 'data/data.txt')
    expected_result = '{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}' + "\n"
    assert_equal expected_result, File.read('result.json')
  end
end

