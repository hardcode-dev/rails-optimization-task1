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
    'sessions' => 0,
    'usedIE' => false,
    'alwaysUsedChrome' => false,
    'totalTime' => 0,
    'maxTime' => 0,
    'browsers' => [],
    'dates' => [],
  }
end

def parse_session(fields)
  {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3].upcase,
    'time' => fields[4].to_i,
    'date' => fields[5].strip,
  }
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.values.each do |user|
    user_key = "#{user['first_name']}" + ' ' + "#{user['last_name']}"
    report['usersStats'][user_key] = yield(user)
  end
end

def parse_file(filename)
  users = {}
  uniq_browsers = []
  total_sessions_count = 0

  File.readlines(filename).each do |line|
    cols = line.split(',')
    users[cols[1]] = parse_user(cols) if cols[0] == 'user'
    next if cols[0] != 'session'

    user = users[cols[1]]
    session = parse_session(cols)
    user['sessions'] += 1
    user['usedIE'] ||= session['browser'].match?(/INTERNET EXPLORER/i)
    user['alwaysUsedChrome'] &= session['browser'].match?(/CHROME/i)
    user['totalTime'] += session['time']
    user['maxTime'] = [user['maxTime'], session['time']].max
    user['browsers'].push session['browser']
    user['dates'].push session['date']
    uniq_browsers.push session['browser']
    total_sessions_count += 1
  end

  [users, uniq_browsers.uniq, total_sessions_count]
end

def work(filename: 'data.txt', gc: true)
  GC.disable unless gc

  users, uniq_browsers, total_sessions_count = parse_file(filename)
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

  report['uniqueBrowsersCount'] = uniq_browsers.count

  report['totalSessions'] = total_sessions_count

  report['allBrowsers'] = uniq_browsers.sort.uniq.join(',')

  # Статистика по пользователям
  # users_objects = []
  # users_sessions = sessions.group_by { |session| session['user_id'] }
  #
  # users.each do |user|
  #   attributes = user
  #   user_sessions = Array(users_sessions[user['id']])
  #   user_object = User.new(attributes: attributes, sessions: user_sessions)
  #   users_objects = users_objects + [user_object]
  # end

  report['usersStats'] = {}

  # Собираем количество сессий по пользователям
  collect_stats_from_users(report, users) do |user|
    {
      'sessionsCount' => user['sessions'],
      'totalTime' => user['totalTime'].to_s + ' min.', # Собираем количество времени по пользователям
      'longestSession' => user['maxTime'].to_s + ' min.', # Выбираем самую длинную сессию пользователя
      'browsers' => user['browsers'].sort.join(', '), # Браузеры пользователя через запятую
      'usedIE' => user['usedIE'], # Хоть раз использовал IE?
      'alwaysUsedChrome' => user['alwaysUsedChrome'], # Всегда использовал только Chrome?
      'dates' => user['dates'].sort.reverse # Даты сессий через запятую в обратном порядке в формате iso8601
    }
  end

  File.write('result.json', "#{report.to_json}\n")

  GC.enable unless gc
end
