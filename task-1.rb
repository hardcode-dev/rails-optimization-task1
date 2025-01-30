# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'
require "set"

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_user(user)
  fields = user.split(',')
  parsed_result = {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

def parse_session(session)
  fields = session.split(',')
  parsed_result = {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5],
  }
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
  end
end

def work(file_path, result_path = 'spec/fixtures/files/result.json')
  file_lines = File.read(file_path).split("\n")

  users = []
  sessions = []

  file_lines.each do |line|
    cols = line.split(',')
    users = users << parse_user(line) if cols[0] == 'user'
    sessions = sessions << parse_session(line) if cols[0] == 'session'
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
  uniqueBrowsers = Set.new
  sessions.each do |session|
    uniqueBrowsers.add(session['browser'])
  end

  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] =
    sessions
      .map { |s| s['browser'] }
      .map { |b| b.upcase }
      .sort
      .uniq
      .join(',')

  user_sessions = sessions.group_by { |session| session['user_id'] }
  # Статистика по пользователям
  users_objects = users.map do |user|
    User.new(attributes: user, sessions: user_sessions[user['id']] || [])
  end

  report['usersStats'] = {}

  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"

    # Подготовим данные для сессий
    sessions = user.sessions
    times = sessions.map { |s| s['time'].to_i }
    browsers = sessions.map { |s| s['browser'].upcase }
    dates = sessions.map { |s| Date.parse(s['date']) }

    report['usersStats'][user_key] = {
      # Количество сессий
      'sessionsCount' => sessions.count,
      # Общее время
      'totalTime' => "#{times.sum} min.",
      # Самая длинная сессия
      'longestSession' => "#{times.max} min.",
      # Браузеры через запятую
      'browsers' => browsers.sort.join(', '),
      # Хоть раз использовал IE?
      'usedIE' => browsers.any? { |b| b.include?('INTERNET EXPLORER') },
      # Всегда использовал только Chrome?
      'alwaysUsedChrome' => browsers.all? { |b| b.include?('CHROME') },
      # Даты сессий через запятую в обратном порядке в формате iso8601
      'dates' => dates.sort.reverse.map(&:iso8601)
    }
  end

  File.write(result_path, "#{report.to_json}\n")
end
