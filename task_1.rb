# frozen_string_literal: true

require 'json'

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
    'time' => fields[4],
    'date' => fields[5]
  }
end

def work(file_name = 'data.txt')
  file_lines = File.read(file_name).split("\n")

  users = []
  sessions = []
  unique_browsers = {}
  sessions_by_user_id = {}

  report = { totalUsers: 0, uniqueBrowsersCount: 0, totalSessions: 0, allBrowsers: nil, usersStats: {} }

  file_lines.each do |line|
    cols = line.split(',')
    case cols[0]
    when 'user'
      users << parse_user(cols)
      report[:totalUsers] += 1
    when 'session'
      session = parse_session(cols)
      sessions << session
      browser = session['browser']
      user_id = session['user_id']
      sessions_by_user_id[user_id] ||= []
      sessions_by_user_id[user_id] << session
      unique_browsers[browser] = nil
      report[:totalSessions] += 1
    end
  end

  unique_browsers = unique_browsers.keys.sort!

  report[:uniqueBrowsersCount] = unique_browsers.count
  report[:allBrowsers] = unique_browsers.join(',')

  # Статистика по пользователям
  users.each do |user|
    user_key = "#{user['first_name']} #{user['last_name']}"
    user_sessions = sessions_by_user_id[user['id']]

    time_sum = 0
    longest_session = 0
    browsers = []
    dates = []

    user_sessions.each do |s|
      time = s['time'].to_i
      browser = s['browser']
      time_sum += time
      longest_session = time if longest_session < time
      browsers << browser
      dates << s['date']
    end

    browsers.sort!
    dates.sort!.reverse!

    report[:usersStats][user_key] = {
      sessionsCount: user_sessions.count,
      totalTime: "#{time_sum} min.",
      longestSession: "#{longest_session} min.",
      browsers: browsers.join(', '),
      usedIE: browsers.any? { |b| b.start_with?('I') },
      alwaysUsedChrome: browsers.all? { |b| b.start_with?('C') },
      dates: dates
    }
  end

  File.write('result.json', "#{report.to_json}\n")
end
