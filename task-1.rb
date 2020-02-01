# frozen_string_literal: true
require 'json'

def work(file_name: 'files/data.txt', rows_count: nil)
  @users = {}
  @report = { totalUsers: 0, uniqueBrowsersCount: 0, totalSessions: 0, allBrowsers: [], usersStats: {} }

  file_lines = parse_file(file_name, rows_count)
  file_lines.each { |line| parse_line(line) }

  @report[:uniqueBrowsersCount] = @report[:allBrowsers].uniq.count
  @report[:allBrowsers]         = @report[:allBrowsers].uniq.sort.join(',')
  @users.each { |_id, user_hash| prepare_user_statistic(user_hash) }

  File.write('files/result.json', "#{@report.to_json}\n")
end

def parse_file(file_name, rows_count)
  rows_count ? File.read('files/data_large.txt').split("\n").first(rows_count) : File.read(file_name).split("\n")
end

def parse_line(line)
  cols = line.split(',')
  cols.first == 'user' ? parse_user(cols) : parse_session(cols)
end

def parse_user(user)
  @users[user[1]] ||= {}
  @users[user[1]].merge!(first_name: user[2], last_name: user[3], age: user[4])
  @report[:totalUsers] += 1
  @users[user[1]][:statistics] ||= initialize_statistics
end

def parse_session(session)
  browser = session[3].upcase
  time = session[4].to_i
  @users[session[1]] ||= {}
  @users[session[1]][:sessions] ||= []
  @users[session[1]][:sessions] <<  {
    session_id: session[2],
    browser: browser,
    time: session[4],
    date: session[5]
  }
  @report[:allBrowsers] << browser
  @report[:totalSessions] += 1
  collect_statistics(session, time, browser)
end

def initialize_statistics
  {
    sessionsCount: 0,
    totalTime: 0,
    longestSession: 0,
    browsers: [],
    usedIE: false,
    alwaysUsedChrome: true,
    dates: []
  }
end

def collect_statistics(session, time, browser)
  @users[session[1]][:statistics] ||= initialize_statistics
  @users[session[1]][:statistics][:sessionsCount] += 1
  @users[session[1]][:statistics][:totalTime] += time
  @users[session[1]][:statistics][:longestSession] = time if time > @users[session[1]][:statistics][:longestSession]
  @users[session[1]][:statistics][:browsers] << browser
  @users[session[1]][:statistics][:dates] << session[5]
end

def prepare_user_statistic(user_hash)
  user_name = [user_hash[:first_name], user_hash[:last_name]].join(' ')
  @report[:usersStats][user_name] =
    {
      sessionsCount: user_hash[:statistics][:sessionsCount],
      totalTime: "#{user_hash[:statistics][:totalTime]} min.",
      longestSession: "#{user_hash[:statistics][:longestSession]} min.",
      browsers: user_hash[:statistics][:browsers].sort.join(', '),
      usedIE: !user_hash[:statistics][:browsers].find { |browser| browser =~ /INTERNET EXPLORER/ }.nil?,
      alwaysUsedChrome: user_hash[:statistics][:browsers].all? { |browser| browser =~ /CHROME/ },
      dates: user_hash[:statistics][:dates].sort.reverse
    }
end
