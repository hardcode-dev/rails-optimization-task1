# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'
require 'ruby-progressbar'

def parse_user(fields)
  {
    id: fields[1],
    full_name: [fields[2], fields[3]].join(' '),
    age: fields[4]
  }
end

def parse_session(fields)
  {
    user_id: fields[1],
    browser: fields[3].upcase,
    time: fields[4],
    date: fields[5]
  }
end

def set_progress_bar(parts_of_work)
  ProgressBar.create(
    total: parts_of_work,
    format: '%a, %J, %E %B'
  )
end

def collect_stats_from_users(report, users, sessions)
  users.each do |user|
    user_key = user[:full_name]
    user_sessions = sessions[user[:id]]
    next unless user_sessions

    browsers = user_sessions.map { |s| s[:browser] }
    report[:usersStats][user_key] = {
      sessionsCount: sessions_count(user_sessions),
      totalTime: total_time(user_sessions),
      longestSession: longest_session(user_sessions),
      browsers: browsers(browsers),
      usedIE: used_ie(browsers),
      alwaysUsedChrome: always_used_chrome(browsers),
      dates: dates(user_sessions)
    }
  end
end

# Собираем количество сессий по пользователям
def sessions_count(sessions)
  sessions.count
end

# Собираем количество времени по пользователям
def total_time(sessions)
  sum = sessions.sum { |s| s[:time].to_i }
  [sum.to_s, 'min.'].join(' ')
end

# Выбираем самую длинную сессию пользователя
def longest_session(sessions)
  max = sessions.max_by { |s| s[:time].to_i }[:time]
  [max.to_s, 'min.'].join(' ')
end

# Браузеры пользователя через запятую
def browsers(browsers)
  browsers.sort.join(', ')
end

# Хоть раз использовал IE?
def used_ie(browsers)
  browsers.any? { |b| b.start_with?('INTERNET EXPLORER') }
end

# Всегда использовал только Chrome?
def always_used_chrome(browsers)
  browsers.all? { |b| b.start_with?('CHROME') }
end

# Даты сессий через запятую в обратном порядке в формате iso8601
def dates(sessions)
  sessions.map { |s| s[:date] }.sort { |a, b| b <=> a }
end

def work(filepath = 'data.txt')
  file_lines = File.read(filepath).split("\n")

  report = {}

  users = []
  sessions = {}
  # progress_bar = set_progress_bar(file_lines.size)
  unique_browsers = Set.new
  sessions_count = 0

  file_lines.each do |line|
    line_in_array = line.split(',')
    first_col = line_in_array.first
    if first_col == 'user'
      users << parse_user(line_in_array)
    elsif first_col == 'session'
      session = parse_session(line_in_array)

      unique_browsers.add session[:browser]
      sessions_count += 1

      sessions[session[:user_id]] ||= []
      sessions[session[:user_id]] << session
      # progress_bar.increment
    end
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

  report[:totalUsers] = users.count
  report[:uniqueBrowsersCount] = unique_browsers.count
  report[:totalSessions] = sessions_count
  report[:allBrowsers] = unique_browsers.sort.join(',')

  # Статистика по пользователям
  report[:usersStats] = {}

  collect_stats_from_users(report, users, sessions)

  File.write('result.json', "#{report.to_json}\n")
end
