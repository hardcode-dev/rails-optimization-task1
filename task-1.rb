# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'

class User
  attr_reader :id, :first_name, :last_name, :age
  attr_accessor :sessions

  def initialize(id:, first_name:, last_name:, age:, sessions: [])
    @id = id
    @first_name = first_name
    @last_name = last_name
    @age = age
    @sessions = sessions
  end
end

def parse_user(user)
  fields = user.split(',')
  parsed_result = {
    id: fields[1],
    first_name: fields[2],
    last_name: fields[3],
    age: fields[4],
  }
end

def parse_session(session)
  fields = session.split(',')
  parsed_result = {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5],
  }
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.first_name}" + ' ' + "#{user.last_name}"
    report['usersStats'][user_key] ||= {}

    user_times = user.sessions.map {|s| s['time']}.map {|t| t.to_i}
    user_browsers = user.sessions.map {|s| s['browser']}

    report['usersStats'][user_key] = report['usersStats'][user_key].merge(
      {
        # # Собираем количество сессий по пользователям
        'sessionsCount' => user.sessions.count,
        # # Собираем количество времени по пользователям
        'totalTime' => user_times.sum.to_s + ' min.',
        # # Выбираем самую длинную сессию пользователя
        'longestSession' => user_times.max.to_s + ' min.',
        # # Браузеры пользователя через запятую
        'browsers' => user_browsers.map {|b| b.upcase}.sort.join(', '),
        # # Хоть раз использовал IE?
        'usedIE' => user_browsers.any? { |b| b.upcase =~ /INTERNET EXPLORER/ },
        # # Всегда использовал только Chrome?
        'alwaysUsedChrome' => user_browsers.all? { |b| b.upcase =~ /CHROME/ },
        # # Даты сессий через запятую в обратном порядке в формате iso8601
        'dates' => user.sessions.map{|s| s['date']}.sort.reverse
      }
    )
  end
end

def split_users_and_sessions(file_lines)
  users = []
  sessions = []

  file_lines.each do |line|
    users << parse_user(line) if line.start_with?('user')
    sessions << parse_session(line) if line.start_with?('session')
  end

  [users, sessions]
end

def initialize_users(users)
  users_objects_by_id = {}

  users.each do |user|
    attributes = user
    user_object = User.new(**attributes)
    users_objects_by_id[user_object.id] = user_object
  end

  users_objects_by_id
end

def assign_sessions_to_users(users_objects_by_id, sessions)
  sessions.each do |session|
    users_objects_by_id[session['user_id']].sessions << session
  end
end

def build_report(users_objects_by_id, sessions)
  users = users_objects_by_id.values

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
  uniqueBrowsers = sessions.map { |s| s['browser'] }.uniq
  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] =
    sessions
      .map { |s| s['browser'] }
      .map { |b| b.upcase }
      .sort
      .uniq
      .join(',')

  # Статистика по пользователям
  report['usersStats'] = {}

  users_objects = users_objects_by_id.values

  collect_stats_from_users(report, users_objects)

  report
end

def work(file_path = 'data.txt', **options)
  GC.disable if options[:disable_gc]

  file_lines = File.read(file_path).split("\n")
  users, sessions = split_users_and_sessions(file_lines)
  users_objects_by_id = initialize_users(users)
  assign_sessions_to_users(users_objects_by_id, sessions)
  report = build_report(users_objects_by_id, sessions)

  File.write('result.json', "#{report.to_json}\n")
ensure
  GC.enable
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
