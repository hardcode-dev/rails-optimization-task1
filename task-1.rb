# Deoptimized version of homework task

require 'json'
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

def work(file_name = 'data/data.txt')
  file_lines = File.read(file_name).split("\n")

  users = []
  sessions = []

  file_lines.each do |line|
    cols = line.split(',')
    case cols[0]
    when 'user'
      users << parse_user(cols)
    when 'session'
      sessions << parse_session(cols)
    end
  end

  report = {}

  report['totalUsers'] = users.count

  # Подсчёт количества уникальных браузеров
  browsers = sessions.map { |s| s['browser'] }.uniq.sort
  report['uniqueBrowsersCount'] = browsers.count
  report['totalSessions'] = sessions.count
  report['allBrowsers'] = browsers.join(',')

  # Статистика по пользователям
  sessions = sessions.group_by { |s| s['user_id'] }

  report['usersStats'] = collect_user_objects(users, sessions)

  File.write('result.json', "#{report.to_json}\n")
end

def collect_user_objects(users, sessions)
  {}.tap do |report|
    users.map do |user|
      user_sessions = sessions[user['id']]
      user_key = "#{user['first_name']} #{user['last_name']}"
      report[user_key] = collect_stats_from_user(user_sessions)
    end
  end
end

def collect_stats_from_user(user_sessions)
  browsers = user_sessions.map { |s| s['browser'] }
  {
    'sessionsCount' => user_sessions.count,
    'totalTime' => "#{user_sessions.sum { |s| s['time'] }} min.",
    'longestSession' => "#{user_sessions.map { |s| s['time'] }.max} min.",
    'browsers' => browsers.sort.join(', '),
    'usedIE' => browsers.any? { |b| b =~ /INTERNET EXPLORER/ },
    'alwaysUsedChrome' => browsers.all? { |b| b =~ /CHROME/ },
    'dates' => user_sessions.map { |s| s['date'] }.sort.reverse
  }
end
