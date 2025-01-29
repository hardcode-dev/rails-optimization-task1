# frozen_string_literal: true

require 'json'
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

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = block.call(user)
  end
end

def work(file = 'data.txt')
  collect_stats(File.read(file).split("\n"))
end

def collect_stats(file_lines)
  users = []
  sessions = []

  file_lines.each do |line|
    cols = line.split(',')
    users << parse_user(cols) if cols[0] == 'user'
    sessions << parse_session(cols) if cols[0] == 'session'
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
  unique_browsers = sessions.map { |session| session['browser'].upcase }.uniq
  report['uniqueBrowsersCount'] = unique_browsers.count
  report['totalSessions'] = sessions.count
  report['allBrowsers'] = unique_browsers.sort.join(',')

  # Статистика по пользователям
  sessions_by_users = sessions.group_by { |session| session['user_id'] }
  users_objects = users.map { |user| User.new(attributes: user, sessions: sessions_by_users[user['id']] || []) }

  report['usersStats'] = {}

  # Собираем количество сессий по пользователям
  collect_stats_from_users(report, users_objects) do |user|
    session_time_list = user.sessions.map { |s| s['time'].to_i }
    session_brouser_list = user.sessions.map { |s| s['browser'].upcase }
    {
      'sessionsCount' => user.sessions.count,
      'totalTime' => "#{session_time_list.sum} min.",
      'longestSession' => "#{session_time_list.max} min.",
      'browsers' => session_brouser_list.sort.join(', '),
      'usedIE' => session_brouser_list.any? { |browser| browser =~ /INTERNET EXPLORER/ },
      'alwaysUsedChrome' => session_brouser_list.all? { |browser| browser =~ /CHROME/ },
      'dates' => user.sessions.map { |s| Date.parse(s['date']) }.sort.reverse.map(&:iso8601)
    }
  end

  File.write('result.json', "#{report.to_json}\n")
end
