# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'set'

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
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5],
  }
end

def collect_stats_from_user(report, user, sessions)
  user_key = "#{user['first_name']} #{user['last_name']}"
  session_count = sessions.count
  total_time = 0
  longest_session = 0
  browsers = []
  used_ie = false
  always_chrome = true
  dates = []
  sessions.each do |session|
    time = session['time'].to_i
    browser = session['browser'].upcase
    total_time += time
    longest_session = time > longest_session ? time : longest_session
    browsers << browser
    unless used_ie
      used_ie = browser[0] == 'I'
    end
    if always_chrome
      always_chrome = browser[0] == 'C'
    end
    dates << session['date']
  end

  report['usersStats'][user_key] = {
    'sessionsCount' => session_count,
    'totalTime' => "#{total_time} min.",
    'longestSession' => "#{longest_session} min.",
    'browsers' => browsers.sort.join(', '),
    'usedIE' => used_ie,
    'alwaysUsedChrome' => always_chrome,
    'dates' => dates.sort.reverse,
  }
end

def work(file_lines:)
  users = []
  sessions = []
  user_sessions = {}

  file_lines.each do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      users << parse_user(cols)
      user_sessions[cols[1]] = []
    end
    if cols[0] == 'session'
      session = parse_session(cols)
      sessions << session
      user_sessions[cols[1]] << session
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

  report[:totalUsers] = users.count

  uniqueBrowsers = Set.new
  sessions.each do |session|
    uniqueBrowsers << session['browser'].upcase
  end

  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] = uniqueBrowsers.sort.join(',')

  # Статистика по пользователям
  report['usersStats'] = {}
  users.each do |user|
    collect_stats_from_user(report, user, user_sessions[user['id']])
  end

  File.write('result.json', "#{report.to_json}\n")
end
