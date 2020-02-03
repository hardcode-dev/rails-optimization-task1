# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'

Session = Struct.new(:user_id, :session_id, :browser, :time, :date)
UserStruct = Struct.new(:id, :first_name, :last_name, :age)

class User
  attr_reader  :sessions
  attr_reader :id, :first_name, :last_name, :age

  def initialize(attributes)
    @id = attributes[:id]
    @first_name = attributes[:first_name]
    @last_name = attributes[:last_name]
    @age = attributes[:age]
    @sessions = []
  end
end

def parse_user(fields)
  # {
  #   id: fields[1].to_i,
  #   first_name: fields[2],
  #   last_name: fields[3],
  #   age: fields[4],
  # }
  #   using Struct gives no speedup on small data
  # User.count much less then Session.count
  UserStruct.new(
      fields[1].to_i,
      fields[2],
      fields[3],
      fields[4],
      )
end

def parse_session(fields)
  # {
  #   user_id: fields[1].to_i,
  #   session_id: fields[2],
  #   browser: fields[3],
  #   time: fields[4],
  #   date: Date.strptime(fields[5]),
  # }
  # Struc gives hire 25% percents speedup
  Session.new(
      fields[1].to_i,
      fields[2],
      fields[3],
      fields[4],
      Date.strptime(fields[5]),
      )
end

def read_file(filename)
  File.read(ENV['DATA_FILE'] || filename).split("\n")
end

def parse_file(file_lines)
  users = []
  sessions = []

  file_lines.each do |line|
    fields = line.split(',')
    if fields[0] == 'user'
      user = User.new(parse_user(fields))
      user_id = user.id
      users[user_id] = user if users[user_id].nil?
    else
      session = parse_session(fields)
      user_id = session[:user_id]
      users[user_id].sessions << session
      sessions << session
    end
  end
  [users, sessions]
end

def unique_browsers(sessions)
  sessions.map{|ss| ss["browser"]}.uniq
end

def get_browsers(sessions)
  sessions
      .map { |s| s['browser'] }
      .uniq
      .sort
      .join(',')
end

def collect_stats(report, users_objects, sessions)
  report[:totalUsers] = users_objects.count

  # Подсчёт количества уникальных браузеров
  uniqueBrowsers = unique_browsers(sessions)

  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] = get_browsers(sessions)

  report['usersStats'] = {}


  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= {}
    # Собираем количество сессий по пользователям
    sessions_count = { 'sessionsCount' => user.sessions.count }
    # Собираем количество времени по пользователям
    total_time = { 'totalTime' => user.sessions.map {|s| s['time']}.sum.to_s + ' min.' }
    # Выбираем самую длинную сессию пользователя
    longest_session = { 'longestSession' => user.sessions.map {|s| s['time']}.max.to_s + ' min.' }
    # Браузеры пользователя через запятую
    browsers = { 'browsers' => user.sessions.map {|s| s['browser']}.sort.join(', ') }
    # Хоть раз использовал IE?
    used_IE = { 'usedIE' => user.sessions.map{|s| s['browser']}.any? { |b| b =~ /INTERNET EXPLORER/ } }
    # Всегда использовал только Chrome?
    always_used_chrome = { 'alwaysUsedChrome' => user.sessions.map{|s| s['browser']}.all? { |b| b =~ /CHROME/ } }
    # Даты сессий через запятую в обратном порядке в формате iso8601
    dates = { 'dates' => user.sessions.map{|s| s['date']}.sort.reverse }
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(
        sessions_count,
        total_time,
        longest_session,
        browsers,
        used_IE,
        always_used_chrome,
        dates
    )
  end
end

def work(filename = 'data_large.txt', disable_gc: false)
  puts 'Start work'
  GC.disable if disable_gc

  file_lines = read_file(filename)

  users_objects, sessions = parse_file file_lines

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

  collect_stats(report, users_objects, sessions)

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
