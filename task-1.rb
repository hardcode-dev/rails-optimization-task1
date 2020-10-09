# frozen_string_literal: true

require 'json'
require 'byebug'
require_relative 'models/user'

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
    'browser' => fields[3].upcase,
    'time' => fields[4].to_i,
    'date' => fields[5]
  }
end

def fill_user_key(user)
  user.attributes['first_name'].to_s + ' ' + user.attributes['last_name'].to_s
end

# def collect_stats_from_users(report, users_objects, &block)
#   users_objects.each do |user|
#     byebug
#     user_key = fill_user_key(user)
#     report['usersStats'][user_key] ||= {}
#     report['usersStats'][user_key] =   report['usersStats'][user_key].merge(block.call(user))
#   end
# end

def sessions_count(user)
  user.sessions.length
end

def total_time(time)
  time.sum.to_s + ' min.'
end

def longest_session(time)
  time.max.to_s + ' min.'
end

def browsers(browsers)
  browsers.sort.join(', ')
end

def used_ie?(browsers)
  browsers.any? { |b| b =~ /INTERNET EXPLORER/ }
end

def always_used_chrome?(browsers)
  browsers.all? { |b| b =~ /CHROME/ }
end

def user_stats(user)
  user_browsers = user.sessions.map { |s| s['browser'] }
  user_times = user.sessions.map { |s| s['time'] }

  { 'sessionsCount' => sessions_count(user),
    'totalTime' => total_time(user_times),
    'longestSession' => longest_session(user_times),
    'browsers' => browsers(user_browsers),
    'usedIE' => used_ie?(user_browsers),
    'alwaysUsedChrome' => always_used_chrome?(user_browsers),
    'dates' => user.sessions.map { |s| s['date'] }.sort.reverse }
end

def work
  file_lines = File.read('data.txt').split("\n")

  users = []
  sessions = []

  file_lines.each do |line|
    fields = line.split(',')
    users << parse_user(fields) if fields[0] == 'user'
    sessions << parse_session(fields) if fields[0] == 'session'
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

  report[:totalUsers] = users.length
  # Подсчёт количества уникальных браузеров
  unique_browsers = sessions.map { |session| session['browser'] }.uniq

  report['uniqueBrowsersCount'] = unique_browsers.length
  report['totalSessions'] = sessions.length
  report['allBrowsers'] = unique_browsers.sort.join(',')

  # Статистика по пользователям
  users_objects = []
  report['usersStats'] = {}

  users.each do |user|
    attributes = user
    user_sessions = sessions.select { |session| session['user_id'] == user['id'] }
    user_object = User.new(attributes: attributes, sessions: user_sessions)
    users_objects += [user_object]
    user_key = fill_user_key(user_object)
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(user_stats(user_object))
  end

  File.write('result.json', "#{report.to_json}\n")
end

work
