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
    'browser' => fields[3].upcase,
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

def sessions_group_by_user(sessions)
  sessions.group_by { |session| session['user_id'] }
end

def work(filename = 'data.txt', disable_gc: true)
  GC.disable if disable_gc

  file_lines = File.read(filename).split("\n")

  users = []
  sessions = []

  lines = file_lines.map { |line| line.split(',') }
  lines.each do |fields|
    users << parse_user(fields) if fields[0] == 'user'
    sessions << parse_session(fields) if fields[0] == 'session'
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

  report = {}

  report[:totalUsers] = users.count

  # Подсчёт количества уникальных браузеров
  report['uniqueBrowsersCount'] = sessions.map {|session| session['browser']}.uniq.count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] =
    sessions
      .map { |s| s['browser'] }
      .sort
      .uniq
      .join(',')

  # Статистика по пользователям
  users_objects = []

  user_sessions = sessions_group_by_user(sessions)
  users.each do |user|
    users_objects << User.new(attributes: user, sessions: user_sessions[user['id']])
  end

  report['usersStats'] = {}

  statistics(report, users_objects)

  File.write('result.json', "#{report.to_json}\n")
end

def statistics(report, users_objects)
  collect_stats_from_users(report, users_objects) do |user|
    {
      # Собираем количество сессий по пользователям
      'sessionsCount' => user.sessions.count,

      # Собираем количество времени по пользователям
      'totalTime' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.',

      # Выбираем самую длинную сессию пользователя
      'longestSession' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.',

      # Браузеры пользователя через запятую
      'browsers' => user.sessions.map {|s| s['browser']}.sort.join(', '),

      # Хоть раз использовал IE?
      'usedIE' => user.sessions.map{|s| s['browser']}.any? { |b| b =~ /INTERNET EXPLORER/ },

      # Всегда использовал только Chrome?
      'alwaysUsedChrome' => user.sessions.map{|s| s['browser']}.all? { |b| b =~ /CHROME/ },

      # Даты сессий через запятую в обратном порядке в формате iso8601
      'dates' => user.sessions.map{|s| s['date']}.sort.reverse
    }
  end
end
