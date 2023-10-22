# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'oj'
require 'English'
require 'set'
require 'byebug'

def parse_user(user)
  fields = user.split(',')
  {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4]
  }
end

def parse_session(session)
  fields = session.split(',')
  {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5]
  }
end

def collect_stats_for_user(report, user, sessions)
  time_sessions = sessions.map { |s| s['time'] }.map(&:to_i)
  browsers = sessions.map { |s| s['browser'] }
  stats = {
    'sessionsCount' => sessions.count,
    'totalTime' => "#{time_sessions.sum} min.",
    'longestSession' => "#{time_sessions.max} min.",
    'browsers' => browsers.map(&:upcase).sort.join(', '),
    'usedIE' => browsers.any? { |b| b.upcase.include?('INTERNET EXPLORER') },
    'alwaysUsedChrome' => browsers.all? { |b| b.upcase.include?('CHROME') },
    'dates' => sessions.map { |s| s['date'] }.map { |d| Date.new(*d.split('-').map(&:to_i)) }.sort.reverse.map(&:iso8601)
  }

  user_key = "#{user['first_name']} #{user['last_name']}"
  report['usersStats'][user_key] = stats
end

def work(path: 'data.txt', disable_gc: false)
  unique_browsers = Set.new
  users = []
  sessions = {}
  current_user = nil
  total_users = 0
  total_sessions = 0

  File.readlines(path, chomp: true).each do |line|
    case line[0]
    when 'u'
      current_user = parse_user(line)
      sessions[current_user['id']] = []
      total_users += 1
      users << current_user
    when 's'
      session = parse_session(line)
      total_sessions += 1
      sessions[current_user['id']] << session
      unique_browsers.add(session['browser'].upcase)
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

  report = {}

  report[:totalUsers] = total_users

  # Подсчёт количества уникальных браузеров

  report['uniqueBrowsersCount'] = unique_browsers.size

  report['totalSessions'] = total_sessions

  report['allBrowsers'] = unique_browsers.sort.join(',')

  report['usersStats'] = {}

  users.each do |user|
    collect_stats_for_user(report, user, sessions[user['id']])
  end

  File.write('result.json', "#{Oj.dump(report, mode: :compat)}\n")
end
