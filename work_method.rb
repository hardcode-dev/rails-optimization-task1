# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'

FIXNUM_MAX = (2**(0.size * 8 - 2) - 1)

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
    'date' => fields[5].chomp
  }
end

def collect_stats_from_users(report, users_objects)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(yield(user))
  end
end

def group_sessions_by(sessions, attr)
  sessions.group_by { |session| session[attr] }
end

def parse_lines(lines)
  users = []
  sessions = []

  lines.each do |line|
    cols = line.split(',')
    users << parse_user(cols) if cols[0] == 'user'
    sessions << parse_session(cols) if cols[0] == 'session'
  end

  [users, sessions]
end

def read_file(filename, number_lines)
  IO.foreach(filename).lazy.take(number_lines).to_a
end

def collect_users_objects(users, sessions)
  users_objects = []

  sessions_grouped_by_user_id = group_sessions_by(sessions, 'user_id')

  users.each do |user|
    attributes = user
    user_sessions = sessions_grouped_by_user_id[user['id']]
    user_object = User.new(attributes: attributes, sessions: user_sessions)
    users_objects << user_object
  end

  users_objects
end

def unique_browsers(sessions)
  group_sessions_by(sessions, 'browser').keys
end

# Number of lines in file: 3250940

def work(filename = 'data.txt', number_lines = FIXNUM_MAX)
  file_lines = read_file(filename, number_lines)

  users, sessions = parse_lines(file_lines)

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
  uniqueBrowsers = unique_browsers(sessions)

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
  users_objects = collect_users_objects(users, sessions)

  report['usersStats'] = {}

  collect_stats_from_users(report, users_objects) do |user|
    user_sessions_times = user.sessions.map {|s| s['time'].to_i}
    user_sessions_browsers = user.sessions.map {|s| s['browser'].upcase}
    {
      'sessionsCount' => user.sessions.count,                                                                 # Собираем количество сессий по пользователям
      'totalTime' => (user_sessions_times.sum.to_s + ' min.'),                 # Собираем количество времени по пользователям
      'longestSession' => (user_sessions_times.max.to_s + ' min.'),            # Выбираем самую длинную сессию пользователя
      'browsers' => user_sessions_browsers.sort.join(', '),                  # Браузеры пользователя через запятую
      'usedIE' => user_sessions_browsers.any? { |b| b =~ /INTERNET EXPLORER/ },           # Хоть раз использовал IE?
      'alwaysUsedChrome' => user_sessions_browsers.all? { |b| b =~ /CHROME/ },            # Всегда использовал только Chrome?
      'dates' => user.sessions.map{|s| s['date']}.sort.reverse # Даты сессий через запятую в обратном порядке в формате iso8601
    }
  end

  File.write('result.json', "#{report.to_json}\n")
end
