# Deoptimized version of homework task

require 'json'
require 'oj'
require 'pry'
require 'date'
require './user'

def parse_user(cols)
  {
    'id' => cols[0],
    'first_name' => cols[1],
    'last_name' => cols[2],
    'age' => cols[3]
  }
end

def parse_session(cols)
  {
    'user_id' => cols[1],
    'session_id' => cols[2],
    'browser' => cols[3],
    'time' => cols[4],
    'date' => cols[5]
  }
end

def work(file_name)
  report = { totalUsers: 0, uniqueBrowsersCount: 0, totalSessions: 0, allBrowsers: [], usersStats: {} }
  
  File.read(file_name).split('user,').each do |user_block|
    next if user_block == ''
    report[:totalUsers] += 1
    user_data = {}
    sessions_count = 0
    total_time = 0
    longest_session = 0
    sessions_browsers = []
    sessions_dates = []
    used_ie = false
    all_chrome = true
    
    lines = user_block.split("\n")
    user_data = parse_user(lines.shift.split(','))
    lines.each do |line|
      next if line == '  '
      cols = line.split(',')

      session_data = parse_session(cols)
      browser = session_data['browser'].upcase
      report[:totalSessions] += 1
      report[:allBrowsers] << browser
      total_time += session_data['time'].to_i
      longest_session = session_data['time'].to_i if session_data['time'].to_i > longest_session
      sessions_browsers << browser
      used_ie = true if browser[0..7].eql?('INTERNET')
      all_chrome = false if browser[0..5] != 'CHROME'
      sessions_dates << session_data['date']
      sessions_count += 1
    end
    report[:usersStats]["#{user_data['first_name']} #{user_data['last_name']}"] = {
      sessionsCount:    sessions_count,
      totalTime:        "#{total_time} min.",
      longestSession:   "#{longest_session} min.",
      browsers:         sessions_browsers.sort.join(', '),
      usedIE:           used_ie,
      alwaysUsedChrome: all_chrome,
      dates:            sessions_dates.sort.reverse
    }
  end
  report[:allBrowsers].uniq!
  report[:uniqueBrowsersCount] = report[:allBrowsers].count
  report[:allBrowsers] = report[:allBrowsers].sort.join(',')
  File.write('jsons/result.json', "#{Oj.dump(report)}\n")
end

# work('data/data_large.txt')