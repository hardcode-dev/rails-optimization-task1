# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
# require 'minitest/autorun'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_user(user)
  fields = user.split(',')
  {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

def parse_session(session)
  fields = session.split(',')
  {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5],
  }
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
  end
end

def work(filename, disable_gc: true)
  GC.disable if disable_gc
  file = File.read(filename)
  users, sessions = collect_data(file)

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
  browsers = unique_browsers(sessions)

  report['uniqueBrowsersCount'] = browsers.count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] =
    sessions
      .map { |s| s['browser'] }
      .map { |b| b.upcase }
      .sort
      .uniq
      .join(',')

  # Статистика по пользователям
  users_objects = generate_users_objects(users, sessions)
  report['usersStats'] = {}

  # Собираем количество сессий по пользователям
  user_sessions_count(report, users_objects)

  # Собираем количество времени по пользователям
  user_time_stat(report, users_objects)

  # Выбираем самую длинную сессию пользователя
  user_longest_session(report, users_objects)

  # Браузеры пользователя через запятую
  user_browsers(report, users_objects)

  # Хоть раз использовал IE?
  uses_ie?(report, users_objects)

  # Всегда использовал только Chrome?
  chrome_only?(report, users_objects)

  # Даты сессий через запятую в обратном порядке в формате iso8601
  user_sessions_dates(report, users_objects)

  File.write('result.json', "#{report.to_json}\n")
  GC.enable if disable_gc
end

def unique_browsers(sessions)
  @unique_browsers ||= sessions.values.flatten.map { |session| session['browser'] }.uniq
end

def generate_users_objects(users, sessions)
  users_objects = []

  users.each do |user|
    user_sessions = sessions["user_#{user['id']}"]
    users_objects << User.new(attributes: user, sessions: user_sessions)
  end
  users_objects
end

def collect_data(file)
  users = []
  sessions = {}

  file.each_line(chomp: true) do |line|
    cols = line.split(',')
    case cols[0]
    when 'user'
      users << parse_user(line)
    when 'session'
      sessions["user_#{cols[1]}"] ||= []
      sessions["user_#{cols[1]}"] << parse_session(line)
    end
  end
  [users, sessions]
end

def user_sessions_count(report, users_objects)
  collect_stats_from_users(report, users_objects) do |user|
    { 'sessionsCount' => user.sessions.count }
  end
end

def user_time_stat(report, users_objects)
  collect_stats_from_users(report, users_objects) do |user|
    { 'totalTime' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.' }
  end
end

def user_longest_session(report, users_objects)
  collect_stats_from_users(report, users_objects) do |user|
    { 'longestSession' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.' }
  end
end

def user_browsers(report, users_objects)
  collect_stats_from_users(report, users_objects) do |user|
    { 'browsers' => user.sessions.map {|s| s['browser']}.map {|b| b.upcase}.sort.join(', ') }
  end
end

def uses_ie?(report, users_objects)
  collect_stats_from_users(report, users_objects) do |user|
    { 'usedIE' => user.sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ } }
  end
end

def chrome_only?(report, users_objects)
  collect_stats_from_users(report, users_objects) do |user|
    { 'alwaysUsedChrome' => user.sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ } }
  end
end

def user_sessions_dates(report, users_objects)
  collect_stats_from_users(report, users_objects) do |user|
    { 'dates' => user.sessions.map{|s| s['date']}.map {|d| Date.parse(d)}.sort.reverse.map { |d| d.iso8601 } }
  end
end

# class TestMe < Minitest::Test
#   def setup
#     File.write('result.json', '')
#     File.write('data.txt',
# 'user,0,Leida,Cira,0
# session,0,0,Safari 29,87,2016-10-23
# session,0,1,Firefox 12,118,2017-02-27
# session,0,2,Internet Explorer 28,31,2017-03-28
# session,0,3,Internet Explorer 28,109,2016-09-15
# session,0,4,Safari 39,104,2017-09-27
# session,0,5,Internet Explorer 35,6,2016-09-01
# user,1,Palmer,Katrina,65
# session,1,0,Safari 17,12,2016-10-21
# session,1,1,Firefox 32,3,2016-12-20
# session,1,2,Chrome 6,59,2016-11-11
# session,1,3,Internet Explorer 10,28,2017-04-29
# session,1,4,Chrome 13,116,2016-12-28
# user,2,Gregory,Santos,86
# session,2,0,Chrome 35,6,2018-09-21
# session,2,1,Safari 49,85,2017-05-22
# session,2,2,Firefox 47,17,2018-02-02
# session,2,3,Chrome 20,84,2016-11-25
# ')
#   end

  # def test_result
  #   work('data.txt', disable_gc: false)
  #   expected_result = '{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}' + "\n"
  #   assert_equal expected_result, File.read('result.json')
  # end
# end
