# frozen_string_literal: true

require 'oj'
require 'json'
require 'set'

USER_ROW = 'user'
SESSION_ROW = 'session'
IE = /^INTERNET EXPLORER/.freeze
CHROME = /^CHROME/.freeze

def parse_user(fields)
  {
    id: fields[1],
    fullname: fields[2] << ' ' << fields[3]
  }
end

def parse_session(fields)
  {
    user_id: fields[1],
    browser: fields[3],
    time: fields[4].to_i,
    date: fields[5].chomp!
  }
end

def work(input_filename: 'data.txt', output_filename: 'result.json')
  users = []
  sessions = {}
  uniq_browsers = Set.new
  report = {
    totalUsers: 0,
    uniqueBrowsersCount: 0,
    totalSessions: 0,
    allBrowsers: '',
    usersStats: {}
  }

  IO.foreach(input_filename).each do |line|
    cols = line.split(',')
    users << parse_user(cols) if line.start_with?(USER_ROW)
    next unless line.start_with?(SESSION_ROW)

    session = parse_session(cols)
    sessions[session[:user_id]] ||= []
    sessions[session[:user_id]] << session
    uniq_browsers << session[:browser].upcase!
    report[:totalSessions] += 1
  end

  report[:totalUsers] = users.count
  report[:uniqueBrowsersCount] = uniq_browsers.count
  report[:allBrowsers] = uniq_browsers.to_a.sort!.join(',')
  report[:usersStats] = {}

  until users.empty?
    user = users.shift
    user_sessions = sessions.delete(user[:id]) || []
    sessions_duration = user_sessions.map { |s| s[:time] }
    browsers = user_sessions.map { |s| s[:browser] }

    report[:usersStats][user[:fullname]] = {
      sessionsCount: user_sessions.count,
      totalTime: "#{sessions_duration.sum} min.",
      longestSession: "#{sessions_duration.max} min.",
      browsers: browsers.sort!.join(', '),
      usedIE: browsers.any? { |b| b =~ IE },
      alwaysUsedChrome: browsers.all? { |b| b =~ CHROME },
      dates: user_sessions.map { |s| s[:date] }.sort!.reverse!
    }
  end

  File.write(output_filename, "#{report.to_json}\n")
end
