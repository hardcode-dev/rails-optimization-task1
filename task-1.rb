# frozen_string_literal: true

# Deoptimized version of homework task

require 'date'
require 'json'
require 'pry'

DEFAULT_PATH = 'data.txt'

class User
  attr_reader :attributes, :sessions, :key

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
    @key = "#{attributes['first_name']} #{attributes['last_name']}"
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
    'browser' => fields[3].upcase,
    'time' => fields[4].to_i,
    'date' => fields[5]
  }
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    report['usersStats'][user.key] ||= {}
    report['usersStats'][user.key] = report['usersStats'][user.key].merge(block.call(user))
  end
end

def work(path = DEFAULT_PATH)
  users = []
  sessions = []
  browsers = []

  File.readlines(path, chomp: true).each do |line|
    cols = line.split(',')
    case cols[0]
    when 'user'
      users << parse_user(cols)
    when 'session'
      session = parse_session(cols)
      sessions << session
      browsers << session['browser']
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

  # Подсчёт количества уникальных браузеров
  uniq_browsers = browsers.uniq

  report = {}
  report['totalUsers'] = users.count
  report['uniqueBrowsersCount'] = uniq_browsers.count
  report['totalSessions'] = sessions.count
  report['allBrowsers'] = uniq_browsers.sort.join(',')
  report['usersStats'] = {}

  # Статистика по пользователям
  users_sessions = sessions.group_by { |s| s['user_id'] }
  users_objects = users.map do |user|
    User.new(attributes: user, sessions: users_sessions[user['id']])
  end

  # Собираем количество сессий по пользователям
  collect_stats_from_users(report, users_objects) do |user|
    { 'sessionsCount' => user.sessions.count }
  end

  # Собираем количество времени по пользователям
  collect_stats_from_users(report, users_objects) do |user|
    { 'totalTime' => "#{user.sessions.map { |s| s['time'] }.sum} min." }
  end

  # Выбираем самую длинную сессию пользователя
  collect_stats_from_users(report, users_objects) do |user|
    { 'longestSession' => "#{user.sessions.map { |s| s['time'] }.max} min." }
  end

  # Браузеры пользователя через запятую
  collect_stats_from_users(report, users_objects) do |user|
    { 'browsers' => user.sessions.map { |s| s['browser'] }.sort.join(', ') }
  end

  # Хоть раз использовал IE?
  collect_stats_from_users(report, users_objects) do |user|
    { 'usedIE' => user.sessions.map { |s| s['browser'] }.any? { |b| b =~ /INTERNET EXPLORER/ } }
  end

  # Всегда использовал только Chrome?
  collect_stats_from_users(report, users_objects) do |user|
    { 'alwaysUsedChrome' => user.sessions.map { |s| s['browser'] }.all? { |b| b =~ /CHROME/ } }
  end

  # Даты сессий через запятую в обратном порядке в формате iso8601
  collect_stats_from_users(report, users_objects) do |user|
    { 'dates' => user.sessions.map { |s| Date.strptime(s['date'], '%Y-%m-%d') }.sort.reverse.map(&:iso8601) }
  end

  File.write('result.json', "#{report.to_json}\n")
end
