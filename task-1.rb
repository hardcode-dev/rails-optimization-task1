# frozen_string_literal: true
# Deoptimized version of homework task

require 'oj'
require 'pry'
require 'date'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_user(fields)
  {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

def parse_session(fields)
  {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3].upcase,
    'time' => fields[4].to_i,
    'date' => fields[5],
  }
end

def collect_stats_from_users(report, users_objects)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= extract_statistics(user)
  end
end

def extract_statistics(user)
  {
    'sessionsCount' => user.sessions.count,
    'totalTime' => user.sessions.map {|s| s['time']}.sum.to_s + ' min.',
    'longestSession' => user.sessions.map {|s| s['time']}.max.to_s + ' min.',
    'browsers' => user.sessions.map {|s| s['browser']}.join(', '),
    'usedIE' => !user.sessions.detect { |s| s['browser'] =~ /INTERNET EXPLORER/ }.nil?,
    'alwaysUsedChrome' => user.sessions.all? { |s| s['browser'] =~ /CHROME/ },
    'dates' => user.sessions.map{|s| s['date']}.sort.reverse
  }
end

def work
  file_lines = File.read('data.txt').split("\n")

  users = []
  sessions = []

  file_lines.each do |line|
    cols = line.split(',')
    users = users + [parse_user(cols)] if cols[0] == 'user'
    sessions = sessions + [parse_session(cols)] if cols[0] == 'session'
  end

  sessions = sessions.sort_by { |s| s['browser'] }

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
  uniqueBrowsers = sessions.map { |s| s['browser'] }.uniq

  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] = uniqueBrowsers.join(',')

  # Статистика по пользователям
  users_objects = []

  user_sessions = sessions.group_by { |session| session['user_id'] }
  users.each do |user|
    attributes = user
    user_object = User.new(attributes: attributes, sessions: user_sessions[user['id']])
    users_objects = users_objects + [user_object]
  end

  report['usersStats'] = {}

  # Собираем количество сессий по пользователям
  collect_stats_from_users(report, users_objects)

  File.write('result.json', "#{Oj.dump(report, mode: :compat)}\n")
end
