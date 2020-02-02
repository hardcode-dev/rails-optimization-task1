# frozen_string_literal: true

# Deoptimized version of homework task
require "set"
require 'oj'

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
    name: fields[2] + ' ' + fields[3]
  }
end

def parse_session(fields)

  {
    user_id: fields[1],
    session_id: fields[2],
    browser: fields[3].upcase,
    time: fields[4].to_i,
    date: fields[5]
  }
end


def fill_report_from_user(user, stats)
  user_key = user.attributes[:name]
  stats[user_key] = yield(user)
end

def collect_stats_from_users(stats, users_objects, &block)
  users_objects.each do |user|
    fill_report_from_user(user, stats, &block)
  end
end

def process_line(users, sessions,line)
  cols = line.split(',')

  if cols[0] == 'session'
    sessions << parse_session(cols)
  elsif cols[0] == 'user'
    users << parse_user(cols)
  end

end

def work
  file_lines = File.read(ENV['FILENAME']).split("\n")

  users = []
  sessions = []

  file_lines.each do |line|
    process_line(users, sessions,line)
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

  unique_browsers = SortedSet.new(sessions.map { |s| s[:browser] })
  report['uniqueBrowsersCount'] = unique_browsers.count
  report['totalSessions'] = sessions.count
  report['allBrowsers'] = unique_browsers.to_a.join(',')



  # Статистика по пользователям

  hashed_sessions = sessions.group_by { |session| session[:user_id] }

  users_objects = users.collect do |user|
    attributes = user
    user_sessions = hashed_sessions[user[:id]] || []

    User.new(attributes: attributes, sessions: user_sessions)
  end

  stats = {}


  collect_stats_from_users(stats, users_objects) do |user|

    browsers = user.sessions.map { |s| s[:browser] }.sort.join(', ')
    only_chrome = user.sessions.all? { |b| b[:browser].include?('CHROME') }
    used_ie = only_chrome ? false : browsers.include?('INTERNET EXPLORER')



    {
        'sessionsCount' => user.sessions.count,  # Собираем количество сессий по пользователям
        'totalTime' => user.sessions.sum { |s| s[:time] }.to_s + ' min.', # Собираем количество времени по пользователям
        'longestSession' => user.sessions.max_by { |s| s[:time] }[:time].to_s + ' min.', # Выбираем самую длинную сессию пользователя
        'browsers' => browsers,  # Браузеры пользователя через запятую
        'usedIE' => used_ie, # Хоть раз использовал IE?
        'alwaysUsedChrome' => only_chrome,  # Всегда использовал только Chrome?
        'dates' => user.sessions.map { |s| s[:date] }.sort.reverse  # Даты сессий через запятую в обратном порядке в формате iso8601
    }
  end


  report['usersStats'] = stats
  Oj.mimic_JSON()
  File.write('result.json', Oj.dump(report) + "\n")
end
