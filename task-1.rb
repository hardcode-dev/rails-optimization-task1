# Deoptimized version of homework task

require 'pry'
require 'date'
require 'oj'
require 'ruby-progressbar'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_user(fields)
  parsed_result = {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

def parse_session(fields)
  parsed_result = {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5],
  }
end

def collect_stats_from_users(report, users_objects)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"
    report['usersStats'][user_key] = data_for_user(user)
    progress_bar.increment
  end
end

def data_for_user(user)
  sessions_times = user.sessions.map { |s| s['time'].to_i }
  sessions_browsers = user.sessions.map { |s| s['browser'].upcase }.sort

  {
    'sessionsCount' => user.sessions.count,   # Собираем количество сессий по пользователям
    'totalTime' => sessions_times.sum.to_s + ' min.', # Собираем количество времени по пользователям
    'longestSession' => sessions_times.max.to_s + ' min.', # Выбираем самую длинную сессию пользователя
    'browsers' => sessions_browsers.join(', '), # Браузеры пользователя через запятую
    'usedIE' => sessions_browsers.any? { |b| b =~ /INTERNET EXPLORER/ }, # Хоть раз использовал IE?
    'alwaysUsedChrome' => sessions_browsers.all? { |b| b =~ /CHROME/ }, # Всегда использовал только Chrome?
    'dates' => user.sessions.map { |s| s['date'] }.sort.reverse, # Даты сессий через запятую в обратном порядке в формате iso8601
  }
end

def progress_bar(total = nil)
  @progress_bar ||= ProgressBar.create(
    total: total, format: '%a, %J, %E, %B'
  )
end

def work(path)
  file_lines = File.read(path).split("\n")

  users = []
  sessions = []

  file_lines.each do |line|
    cols = line.split(',')
    users << parse_user(cols) if cols[0] == 'user'
    sessions << parse_session(cols) if cols[0] == 'session'
  end

  progress_bar(users.count)

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

  report['totalUsers'] = users.count

  # Подсчёт количества уникальных браузеров
  uniqueBrowsers = sessions.map { |session| session['browser'] }.uniq

  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] =
    sessions
      .map { |s| s['browser'].upcase }
      .sort
      .uniq
      .join(',')

  # Статистика по пользователям
  users_objects = []

  grouped_sessions = sessions.group_by { |session| session['user_id'] }
  users.each do |user|
    attributes = user
    user_sessions = grouped_sessions[user['id']]
    users_objects << User.new(attributes: attributes, sessions: user_sessions)
  end

  report['usersStats'] = {}

  collect_stats_from_users(report, users_objects)

  File.write('result.json', Oj.dump(report) + "\n")
end
