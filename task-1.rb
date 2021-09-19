# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'
require 'benchmark'
# require 'benchmark/ips'

def json_report(users:, sessions:)
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

  sessions_by_browsers = sessions.group_by { |h| h['browser']}

  # Подсчёт количества уникальных браузеров
  uniqueBrowsers = []
  # sessions_by_browsers

  browsers = sessions_by_browsers.map do |browser|
    uniqueBrowsers << browser[0]
    browser[0].upcase
  end

  report[:uniqueBrowsersCount] = uniqueBrowsers.count

  report[:totalSessions] = sessions.count

  report[:allBrowsers] = browsers.sort.join(',')

  record_users_statistics(report: report, users: users, sessions: sessions)
end

def calcum_data_from_user(report:, user_sessions:)
  time_collection = []
  browsers_collection = []
  date_collection = []

  user_sessions.map do |s|
    time_collection << s['time'].to_i
    browsers_collection << s['browser'].upcase
    date_collection << Date.strptime(s['date'].to_s.chomp, '%Y-%m-%d').to_s
  end

  browsers_collection.sort!

  { 
    # Собираем количество сессий по пользователям
    'sessionsCount' => user_sessions.count,
    # Собираем количество времени по пользователям
    'totalTime' => time_collection.sum.to_s + ' min.',
    # Выбираем самую длинную сессию пользователя
    'longestSession' => time_collection.max.to_s + ' min.',
    # Браузеры пользователя через запятую
    'browsers' => browsers_collection.join(', '),
    # Хоть раз использовал IE?
    'usedIE' => browsers_collection.any? { |b| b.include? "INTERNET EXPLORER" },
    # Всегда использовал только Chrome?
    'alwaysUsedChrome' => browsers_collection.all? { |b| b.include? "CHROME" },
    # Даты сессий через запятую в обратном порядке в формате iso8601
    'dates' => date_collection.sort.reverse
  }
end

def record_users_statistics(report:, users:, sessions:)
    # Статистика по пользователям
    users_objects = []
    
    sessions_by_user = sessions.group_by { |h| h['user_id']}

    report[:usersStats] = {}

    s = sessions
    users.each do |user|
      id = user['id']
      user_sessions = sessions_by_user[id]

      user_key = "#{user['first_name']} #{user['last_name']}"
      report[:usersStats][user_key] = calcum_data_from_user(report: report, user_sessions: user_sessions)
    end
  
    File.write('result.json', "#{report.to_json}\n")
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

def work(filename, disable_gc = false)
  GC.disable if disable_gc

  time = Benchmark.realtime do
    users = []
    sessions = []

    File.readlines(filename).map do |line|
      cols = line.split(',')
      users << parse_user(cols) if cols[0] == 'user'
      sessions << parse_session(cols) if cols[0] == 'session'
    end

    json_report(users: users, sessions: sessions)
  end

  puts "Time for #{filename} is #{time.round(2)}"
end

class TestMe < Minitest::Test
  def setup
    File.write('result.json', '')
    File.write('fixtures/data.txt',
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
    work('fixtures/data.txt')
    expected_result = '{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}' + "\n"
    assert_equal expected_result, File.read('result.json')
  end
end
