# Deoptimized version of homework task

require 'pry'
require 'date'
require 'oj'
require 'ruby-progressbar'

class User
  attr_reader :attributes
  attr_accessor :sessions

  def initialize(attributes:)
    @attributes = attributes
    @sessions = []
  end
end

def parse_user(fields)
  User.new(attributes: {
    'id': fields[1],
    'first_name': fields[2],
    'last_name': fields[3],
    'age': fields[4],
  })
end

def parse_session(fields)
  {
    'user_id': fields[1],
    'session_id': fields[2],
    'browser': fields[3],
    'time': fields[4],
    'date': fields[5],
  }
end

def collect_stats_from_users(users)
  report = {}
  users.each do |user|
    user_key = "#{user.attributes[:first_name]} #{user.attributes[:last_name]}"
    report[user_key] = data_for_user(user)
    progress_bar.increment
  end

  report
end

def data_for_user(user)
  sessions_times = user.sessions.map { |s| s[:time].to_i }
  sessions_browsers = user.sessions.map { |s| s[:browser].upcase }.sort

  {
    'sessionsCount' => user.sessions.count,   # Собираем количество сессий по пользователям
    'totalTime' => sessions_times.sum.to_s + ' min.', # Собираем количество времени по пользователям
    'longestSession' => sessions_times.max.to_s + ' min.', # Выбираем самую длинную сессию пользователя
    'browsers' => sessions_browsers.join(', '), # Браузеры пользователя через запятую
    'usedIE' => sessions_browsers.any? { |b| b =~ /INTERNET EXPLORER/ }, # Хоть раз использовал IE?
    'alwaysUsedChrome' => sessions_browsers.all? { |b| b =~ /CHROME/ }, # Всегда использовал только Chrome?
    'dates' => user.sessions.map { |s| s[:date] }.sort.reverse, # Даты сессий через запятую в обратном порядке в формате iso8601
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
    if cols[0] == 'session'
      session = parse_session(cols)
      users.last.sessions << session
      sessions << session
    end
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
  unique_browsers = sessions.map { |session| session[:browser] }.uniq

  report['uniqueBrowsersCount'] = unique_browsers.count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] =
    unique_browsers.map(&:upcase)
      .sort
      .join(',')

  # Статистика по пользователям
  
  report['usersStats'] = collect_stats_from_users(users)

  File.write('result.json', Oj.dump(report) + "\n")
end
