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

def parse_user(user)
  fields = user.split(',')
  parsed_result = {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
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
    user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"
    report['usersStats'][user_key] = block.call(user)
  end
end

def work(filename)
  file_lines = File.read(filename).split("\n")

  users = []
  sessions = []

  file_lines.each do |line|
    cols = line.split(',')
    users.append(parse_user(line)) if cols[0] == 'user'
    sessions.append(parse_session(line)) if cols[0] == 'session'
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
  uniqueBrowsers = sessions.map { |session| session['browser'] }.uniq

  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] =
    sessions
      .map { |s| s['browser'] }
      .map(&:upcase)
      .sort
      .uniq
      .join(',')

  # Статистика по пользователям
  user_sessions = sessions.group_by { |session| session['user_id'] }
  users_objects = users.map do |user|
    User.new(attributes: user, sessions: user_sessions[user['id']] || [])
  end

  report['usersStats'] = {}

  collect_stats_from_users(report, users_objects) do |user|
    user_session_time = user.sessions.map { |s| s['time'].to_i }
    user_session_browser = user.sessions.map { |s| s['browser'].upcase }.sort

    {
      # Собираем количество сессий по пользователям
      'sessionsCount' => user.sessions.count,

      # Собираем количество времени по пользователям
      'totalTime' => "#{user_session_time.sum} min.",

      # Выбираем самую длинную сессию пользователя
      'longestSession' => "#{user_session_time.max} min.",

      # Браузеры пользователя через запятую
      'browsers' => user_session_browser.join(', '),

      # Хоть раз использовал IE?
      'usedIE' => user_session_browser.any? { |b| b =~ /INTERNET EXPLORER/ },

      # Всегда использовал только Chrome?
      'alwaysUsedChrome' => user_session_browser.all? { |b| b =~ /CHROME/ },

      # Даты сессий через запятую в обратном порядке в формате iso8601
      'dates' => user.sessions.map { |s| s['date'] }.sort.reverse
    }
  end

  File.write('result.json', "#{report.to_json}\n")
end
