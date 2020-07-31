# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_user(fields)
  {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

def parse_session(fields)
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
    report['usersStats'][user_key] = yield(user)
  end
end

def parse_file(filename)
  users = []
  sessions = []

  File.readlines(filename).each do |line|
    cols = line.split(',')
    users.push(parse_user(cols)) if cols[0] == 'user'
    sessions.push(parse_session(cols)) if cols[0] == 'session'
  end

  [users, sessions]
end

def work(filename: 'data.txt', gc: true)
  GC.disable unless gc

  users, sessions = parse_file(filename)
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
  uniqueBrowsers = sessions.map { |session| session['browser'] }.uniq

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
  users_objects = []
  users_sessions = sessions.group_by { |session| session['user_id'] }

  users.each do |user|
    attributes = user
    user_sessions = Array(users_sessions[user['id']])
    user_object = User.new(attributes: attributes, sessions: user_sessions)
    users_objects = users_objects + [user_object]
  end

  report['usersStats'] = {}

  # Собираем количество сессий по пользователям
  collect_stats_from_users(report, users_objects) do |user|
    times = user.sessions.map { |s| s['time'].to_i }
    browsers = user.sessions.map { |s| s['browser'].upcase }.sort
    {
      'sessionsCount' => user.sessions.count,
      'totalTime' => times.sum.to_s + ' min.', # Собираем количество времени по пользователям
      'longestSession' => times.max.to_s + ' min.', # Выбираем самую длинную сессию пользователя
      'browsers' => browsers.join(', '), # Браузеры пользователя через запятую
      'usedIE' => browsers.any? { |b| b =~ /INTERNET EXPLORER/ }, # Хоть раз использовал IE?
      'alwaysUsedChrome' => browsers.all? { |b| b =~ /CHROME/ }, # Всегда использовал только Chrome?
      'dates' => user.sessions.map{|s| s['date'].strip }.sort.reverse # Даты сессий через запятую в обратном порядке в формате iso8601
    }
  end

  File.write('result.json', "#{report.to_json}\n")

  GC.enable unless gc
end
