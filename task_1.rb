# frozen_string_literal: true

# Unoptimized version of homework task

require 'json'
require 'pry'
require 'set'

def work(file = 'data/data.txt', disable_gc: false)
  puts 'Start work'
  GC.disable if disable_gc

  file_lines = File.read(ENV['DATA_FILE'] || file).split("\n")

  users = {}
  sessions = {}
  unique_browsers = Set[]
  total_sessions = 0
  puts file_lines.count

  file_lines.each do |line|
    cols = line.split(',')
    case cols[0]
    when 'user'
      hash = parse_user(line)
      users[hash[:id]] = hash
    when 'session'
      hash = parse_session(line)
      sessions[hash[:user_id]] ||= []
      sessions[hash[:user_id]] += [hash]
      unique_browsers.add hash[:browser]
      total_sessions += 1
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

  report = {
    totalUsers: users.count,
    uniqueBrowsersCount: unique_browsers.count,
    totalSessions: total_sessions,
    allBrowsers: unique_browsers.to_a.sort.join(',')
  }

  collect_stats_from_users(report, users, sessions)

  File.write('results/result.json', "#{report.to_json}\n")
end

def parse_user(user)
  fields = user.split(',')
  {
    id: fields[1],
    first_name: fields[2],
    last_name: fields[3],
    age: fields[4]
  }
end

def parse_session(session)
  fields = session.split(',')
  {
    user_id: fields[1],
    session_id: fields[2],
    browser: fields[3].upcase,
    time: fields[4].to_i,
    date: fields[5]
  }
end

def collect_stats_from_users(report, users, sessions)
  users.each do |user|
    user_key = "#{user[1][:first_name]} #{user[1][:last_name]}"
    report[:usersStats] ||= {}
    report[:usersStats][user_key] ||= {}
    report[:usersStats][user_key] = {
      sessionsCount: sessions[user[0]].count,
      totalTime: "#{sessions[user[0]].map { |s| s[:time] }.sum.to_s} min.",
      longestSession: "#{sessions[user[0]].map { |s| s[:time] }.max.to_s} min.",
      browsers: sessions[user[0]].map { |s| s[:browser] }.sort.join(', '),
      usedIE: sessions[user[0]].any? { |s| s[:browser] if s[:browser].start_with?('INTERNET EXPLORER') },
      alwaysUsedChrome: sessions[user[0]].all? { |s| s[:browser] if s[:browser].start_with?('CHROME') },
      dates: sessions[user[0]].map { |s| s[:date] }.sort.reverse
    }
  end
end
