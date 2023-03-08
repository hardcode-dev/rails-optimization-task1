# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_user(user_fields)
  {
    'id' => user_fields[1],
    'first_name' => user_fields[2],
    'last_name' => user_fields[3],
    'age' => user_fields[4]
  }
end

def parse_session(session_fields)
  {
    'user_id' => session_fields[1],
    'session_id' => session_fields[2],
    'browser' => session_fields[3],
    'time' => session_fields[4],
    'date' => session_fields[5]
  }
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
  end
end

def read_file(file_path)
  file_lines = File.read(file_path).split("\n")

  users = []
  sessions = []

  file_lines.each do |line|
    cols = line.split(',')
    users << parse_user(cols) if cols[0] == 'user'
    sessions << parse_session(cols) if cols[0] == 'session'
  end

  [users, sessions]
end

def find_uniq_browsers(sessions)
  sessions.uniq { |session| session['browser'] }
end

def user_objects_initialization(users, sessions)
  sessions_by_user = sessions.group_by { |session| session['user_id'] }

  users.map do |user_attributes|
    User.new(attributes: user_attributes, sessions: sessions_by_user[user_attributes['id']])
  end
end

def work(file_path: 'data/data.txt', disable_gc: false)
  GC.disable if disable_gc

  users, sessions = read_file(file_path)

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

  report = {}

  report[:totalUsers] = users.count

  # Подсчёт количества уникальных браузеров
  report['uniqueBrowsersCount'] = find_uniq_browsers(sessions).count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] =
    sessions
      .map { |s| s['browser'] }
      .map { |b| b.upcase }
      .sort
      .uniq
      .join(',')

  # Статистика по пользователям
  users_objects = user_objects_initialization(users, sessions)

  report['usersStats'] = {}

  collect_stats_from_users(report, users_objects) do |user|
    user_sessions = user.sessions
    user_browsers = []
    user_times = []
    user_sessions.each do |s|
      user_browsers << s['browser'].upcase
      user_times << s['time'].to_i
    end

    {
      'sessionsCount' => user_sessions.count, # Собираем количество сессий по пользователям
      'totalTime' => "#{user_times.sum} min.", # Собираем количество времени по пользователям
      'longestSession' => "#{user_times.max} min.", # Выбираем самую длинную сессию пользователя
      'browsers' => user_browsers.sort.join(', '), # Браузеры пользователя через запятую
      'usedIE' => user_browsers.any? { |b| b =~ /INTERNET EXPLORER/ }, # Хоть раз использовал IE?
      'alwaysUsedChrome' => user_browsers.all? { |b| b =~ /CHROME/ }, # Всегда использовал только Chrome?
      # Даты сессий через запятую в обратном порядке в формате iso8601
      'dates' => user_sessions.map { |s| s['date'] }.sort.reverse
    }
  end

  File.write('data/result.json', "#{report.to_json}\n")
end

class TestMe < Minitest::Test
  def setup
    File.write('data/result.json', '')
    File.write('data/data.txt',
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
    assert_equal expected_result, File.read('data/result.json')
  end
end
