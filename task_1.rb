# frozen_string_literal: true

require 'json'
require 'pry'
require 'date'

# User class for report
class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end
def work(filename)
  # GC.disable

  puts 'Start work'

  file = File.read(filename)
  users = []
  sessions = {}

  collect_data(file, users, sessions)
  users_objects = generate_users_objects(users, sessions)

  report = {}
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

  # Статистика по сессиям
  generate_sessions_report(report, users, sessions)
  # Статистика по пользователям
  generate_users_report(report, users_objects)

  File.write('result.json', "#{report.to_json}\n")
  puts 'Finish work'
end

private

def parse_user(cols)
  {
    'id' => cols[1],
    'first_name' => cols[2],
    'last_name' => cols[3],
    'age' => cols[4]
  }
end

def parse_session(cols)
  {
    'user_id' => cols[1],
    'session_id' => cols[2],
    'browser' => cols[3].upcase,
    'time' => cols[4],
    'date' => cols[5]
  }
end

def unique_browsers(sessions)
  @unique_browsers ||= sessions.map { |session| session['browser'] }.uniq
end

def generate_users_objects(users, sessions)
  users_objects = []

  users.each do |user|
    user_sessions = sessions["user_#{user['id']}"]
    users_objects << User.new(attributes: user, sessions: user_sessions)
  end
  users_objects
end

def collect_data(file, users, sessions)
  file.each_line(chomp: true) do |line|
    cols = line.split(',')
    case cols[0].strip
    when 'user'
      users << parse_user(cols)
    when 'session'
      sessions["user_#{cols[1]}"] ||= []
      sessions["user_#{cols[1]}"] << parse_session(cols)
    end
  end
end

def generate_sessions_report(report, users, sessions)
  sessions = sessions.values.flatten
  report['totalUsers'] = users.count
  report['uniqueBrowsersCount'] = unique_browsers(sessions).count
  report['totalSessions'] = sessions.count
  report['allBrowsers'] = unique_browsers(sessions).sort.join(',')
end

def generate_users_report(report, users_objects)
  report['usersStats'] = {}
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"
    report['usersStats'][user_key] = report_for_user(user)
  end
end

def report_for_user(user)
  {
    # Собираем количество сессий по пользователям
    'sessionsCount' => sessions_count(user.sessions),
    # Собираем количество времени по пользователям
    'totalTime' => total_time(user.sessions),
    # Выбираем самую длинную сессию пользователя
    'longestSession' => longest_session(user.sessions),
    # Браузеры пользователя через запятую
    'browsers' => user_browsers(user.sessions),
    # Хоть раз использовал IE?
    'usedIE' => used_ie?(user.sessions),
    # Всегда использовал только Chrome?
    'alwaysUsedChrome' => always_used_chrome?(user.sessions),
    # Даты сессий через запятую в обратном порядке в формате iso8601
    'dates' => user_sessions_dates(user.sessions)
  }
end

def sessions_count(sessions)
  sessions.count
end

def total_time(sessions)
  "#{sessions.map { |s| s['time'].to_i }.sum} min."
end

def longest_session(sessions)
  "#{sessions.map { |s| s['time'].to_i }.max} min."
end

def user_browsers(sessions)
  sessions.map { |s| s['browser'] }.sort.join(', ')
end

def used_ie?(sessions)
  sessions.map { |s| s['browser'] }.any? { |b| b =~ /INTERNET EXPLORER/ }
end

def always_used_chrome?(sessions)
  sessions.map { |s| s['browser'] }.all? { |b| b =~ /CHROME/ }
end

def user_sessions_dates(sessions)
  sessions.map { |s| s['date'] }.sort.reverse
end