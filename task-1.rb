# frozen_string_literal: true

# Deoptimized version of homework task

require 'json'

require 'time'
require_relative 'models/user'

def parse_user(user)
  fields = user.split(',')
  parsed_result = {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4]
  }
end

def parse_session(session)
  fields = session.split(',')
  parsed_result = {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5]
  }
end

def fill_user_key(user)
  user.attributes['first_name'].to_s + ' ' + user.attributes['last_name'].to_s
end

def fill_usersStats(block, report, user, user_key)
  report['usersStats'][user_key].merge(block.call(user))
end

def collect_stats_from_single_user(block, report, user)
  user_key = fill_user_key(user)
  report['usersStats'][user_key] ||= {}
  report['usersStats'][user_key] = fill_usersStats(block, report, user, user_key)
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    collect_stats_from_single_user(block, report, user)
  end
end

def fill_sessions(sessions, user)
  sessions.select { |session| session['user_id'] == user['id'] }
end

def fill_user_object(attributes, user_sessions)
  User.new(attributes: attributes, sessions: user_sessions)
end

def sessions_count(user)
  user.sessions.count
end

def total_time(user)
  user.sessions.map { |s| s['time'] }.map(&:to_i).sum.to_s + ' min.'
end

def longest_session(user)
  user.sessions.map { |s| s['time'] }.map(&:to_i).max.to_s + ' min.'
end

def browsers(user)
  user.sessions.map { |s| s['browser'] }.map(&:upcase).sort.join(', ')
end

def used_ie?(user)
  user.sessions.map { |s| s['browser'] }.any? { |b| b.upcase =~ /INTERNET EXPLORER/ }
end

def always_used_chrome?(user)
  user.sessions.map { |s| s['browser'] }.all? { |b| b.upcase =~ /CHROME/ }
end

def map_sessions(user)
  user.sessions.map { |s| s['date'] }
end

def convert_dates(sessions)
  sessions.map { |d| Date.iso8601(d.chomp) }
end

def dates(user)
  sessions = map_sessions(user)
  dates = convert_dates(sessions)
  dates.sort.reverse
end

def collect_all_stats(report, users_objects)
  # Собираем количество сессий по пользователям
  collect_stats_from_users(report, users_objects) do |user|
    { 'sessionsCount' => sessions_count(user),
      'totalTime' => total_time(user),
      'longestSession' => longest_session(user),
      'browsers' => browsers(user),
      'usedIE' => used_ie?(user),
      'alwaysUsedChrome' => always_used_chrome?(user),
      'dates' => dates(user) }
  end
end

def browser_uniq?(browser, uniqueBrowsers)
  uniqueBrowsers.all? { |b| b != browser }
end

def fill_all_browsers(report, sessions)
  report['allBrowsers'] =
    sessions
      .map { |s| s['browser'] }
      .map { |b| b.upcase }
      .sort
      .uniq
      .join(',')
end

def work
  file_lines = File.read('data.txt').split("\n")

  users = []
  sessions = []

  file_lines.each do |line|
    cols = line.split(',')
    users += [parse_user(line)] if cols[0] == 'user'
    sessions += [parse_session(line)] if cols[0] == 'session'
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
  uniqueBrowsers = []
  sessions.each do |session|
    browser = session['browser']
    uniqueBrowsers += [browser] if browser_uniq?(browser, uniqueBrowsers)
  end

  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = sessions.count

  fill_all_browsers(report, sessions)

  # Статистика по пользователям
  users_objects = []

  users.each do |user|
    attributes = user
    user_sessions = fill_sessions(sessions, user)
    user_object = fill_user_object(attributes, user_sessions)
    users_objects += [user_object]
  end

  report['usersStats'] = {}

  collect_all_stats(report, users_objects)

  File.write('result.json', "#{report.to_json}\n")
end

