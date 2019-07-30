# frozen_string_literal: true

# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
# gem install oj
require 'oj'

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
    id: fields[1],
    first_name:  fields[2],
    last_name: fields[3],
    full_name: "#{fields[2]} #{fields[3]}",
    age: fields[4]
  }
end

def parse_session(fields)
  {
    user_id: fields[1],
    session_id: fields[2],
    browser: fields[3].upcase!,
    time: fields[4].to_i,
    date: fields[5].chomp!
  }
end

def collect_stats_from_users(report, users_objects)
  users_objects.each do |user|
    user_key = user.attributes[:full_name]
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key].merge!(yield(user))
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
  sessions_grouped_by_user_id = group_sessions_by(sessions, :user_id)

  users.map do |user|
    User.new(attributes: user, sessions: sessions_grouped_by_user_id[user[:id]])
  end
end

def unique_browsers(sessions)
  group_sessions_by(sessions, :browser).keys
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

  report['totalUsers'] = users.length

  # Подсчёт количества уникальных браузеров
  uniqueBrowsers = unique_browsers(sessions)

  report['uniqueBrowsersCount'] = uniqueBrowsers.length

  report['totalSessions'] = sessions.length

  report['allBrowsers'] = uniqueBrowsers.sort!.join(',')

  # Статистика по пользователям
  users_objects = collect_users_objects(users, sessions)

  report['usersStats'] = {}

  collect_stats_from_users(report, users_objects) do |user|
    user_sessions = user.sessions
    user_sessions_times = user_sessions.map { |s| s[:time] }
    user_sessions_browsers = user_sessions.map { |s| s[:browser] }
    {
      'sessionsCount' => user_sessions.length, # Собираем количество сессий по пользователям
      'totalTime' => "#{user_sessions_times.sum} min.",                 # Собираем количество времени по пользователям
      'longestSession' => "#{user_sessions_times.max} min.",            # Выбираем самую длинную сессию пользователя
      'browsers' => user_sessions_browsers.sort.join(', '), # Браузеры пользователя через запятую
      'usedIE' => user_sessions_browsers.any? { |b| b =~ /INTERNET EXPLORER/ },           # Хоть раз использовал IE?
      'alwaysUsedChrome' => user_sessions_browsers.all? { |b| b =~ /CHROME/ },            # Всегда использовал только Chrome?
      'dates' => user_sessions.map! { |s| s[:date] }.sort!.reverse! # Даты сессий через запятую в обратном порядке в формате iso8601
    }
  end

  File.write('result.json', "#{Oj.dump(report)}\n")
end
