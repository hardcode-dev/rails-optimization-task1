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
    'age' => fields[4]
  }
end

def parse_session(fields)
  {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5]
  }
end

def collect_data(filename)
  users = []
  sessions = []

  File.read(filename).split("\n").each do |line|
    cols = line.split(',')
    case cols[0]
    when 'user'
      users << parse_user(cols)
    when 'session'
      sessions << parse_session(cols)
    end
  end

  [users, sessions]
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"
    report['usersStats'][user_key] = block.call(user)
  end
end

def work(filename = 'data_large.txt', disable_gc: false)
  GC.disable if disable_gc

  users, sessions = collect_data(filename)

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

  report['allBrowsers'] = sessions.map { |s| s['browser'].upcase }.uniq.sort.join(',')

  grouped_sessions = sessions.group_by { |session| session['user_id'] }

  # Статистика по пользователям
  users_objects = users.map do |user|
    User.new(attributes: user, sessions: grouped_sessions[user['id']] || [])
  end

  report['usersStats'] = {}

  # Собираем количество сессий по пользователям
  collect_stats_from_users(report, users_objects) do |user|
    browsers_upcased = user.sessions.map { |s| s['browser'].upcase }
    sessions_time = user.sessions.map { |s| s['time'].to_i }
    {
      'sessionsCount' => user.sessions.count,
      'totalTime' => "#{sessions_time.sum} min.",
      'longestSession' => "#{sessions_time.max} min.",
      'browsers' => browsers_upcased.sort.join(', '),
      'usedIE' => browsers_upcased.any? { |b| b =~ /INTERNET EXPLORER/ },
      'alwaysUsedChrome' => browsers_upcased.all? { |b| b =~ /CHROME/ },
      'dates' => user.sessions.map { |s| s['date'] }.sort.reverse
    }
  end

  File.write('result.json', "#{report.to_json}\n")
end
