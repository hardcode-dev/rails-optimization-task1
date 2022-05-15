# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'

class User
  attr_reader :attributes, :sessions
  attr_accessor :ie_user

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
    @ie_user = false
  end
end

def parse_user(user)
  {
    'id' => user[1],
    'first_name' => user[2],
    'last_name' => user[3],
    'age' => user[4],
  }
end

def parse_session(session)
  {
    'user_id' => session[1],
    'session_id' => session[2],
    'browser' => session[3],
    'time' => session[4],
    'date' => session[5],
  }
end

def collect_stats_from_users(user)
  total_time = 0
  longest_session = 0
  browsers = []
  dates_strings = []
  user.sessions.map do |session|
    time = session['time'].to_i
    total_time += time
    longest_session = time if time > longest_session
    browser = session['browser'].upcase
    browsers << browser
    user.ie_user = true if browser.start_with? 'INTERNET EXPLORER'
    dates_strings << session['date']
  end

  always_use_chrome = user.ie_user ? false : browsers.all? { |b| b.start_with? 'CHROME' }

  {
    'sessionsCount' => user.sessions.count,
    'totalTime' => "#{total_time} min.",
    'longestSession' => "#{longest_session} min.",
    'browsers' => browsers.sort.join(', '),
    'usedIE' => user.ie_user,
    'alwaysUsedChrome' => always_use_chrome,
    'dates' => dates_strings.sort_by{ |d| y,m,d = d.split('-') }.reverse,
  }
end

def work(file_name: 'data.txt', disabled_gc: false)
  GC.disable if disabled_gc
  file_lines = File.read(file_name).split("\n")

  sessions_count = 0
  all_browsers = []

  # {"0"=>{:data=>{"id"=>"0", "first_name"=>"Leida", "last_name"=>"Cira", "age"=>"0"}, :sessions=>[]}
  report_data = {}
  file_lines.each do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      parsed_user = parse_user(cols)
      report_data.merge!({ parsed_user['id'] => { data: parsed_user, sessions: []} })
    end
    if cols[0] == 'session'
      parsed_session = parse_session(cols)
      report_data[parsed_session['user_id']][:sessions] << parsed_session
      browser = parsed_session['browser']
      all_browsers << browser.upcase
      sessions_count += 1
    end
  end

  users_objects = []
  report_data.each do |_k, v|
    attrs = v[:data]
    sessions = v[:sessions]
    user_object = User.new(attributes: attrs, sessions: sessions)
    users_objects << user_object
  end

  # Отчёт в json
  #   - Сколько всего юзеров +
  #   - Сколько всего уникальных браузеров +
  #   - Сколько всего сессий +
  #   - Перечислить уникальные браузеры в алфавитном порядке через запятую и капсом +
  #
  #   - По каждому пользователю
  #     - сколько всего сессий +
  #     - сколько всего времени +
  #     - самая длинная сессия +
  #     - браузеры через запятую +
  #     - Хоть раз использовал IE? +
  #     - Всегда использовал только Хром? +
  #     - даты сессий в порядке убывания через запятую +

  uniq_browsers = all_browsers.uniq

  report = {}
  report['totalUsers'] = users_objects.count
  report['uniqueBrowsersCount'] = uniq_browsers.count
  report['totalSessions'] = sessions_count
  report['allBrowsers'] = uniq_browsers.sort.join(',')

  report['usersStats'] = {}

  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge!(collect_stats_from_users(user))
  end

  File.write('result.json', "#{report.to_json}\n")
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
