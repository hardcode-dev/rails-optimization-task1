# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'
require_relative 'user'

def file_lines
  File.read('data.txt').split("\n")
end

def users_sessions
  users = []
  users_count = 0
  sessions = []
  grouped_sessions = {}
  sessions_count = 0
  browser_names = {}

  lines = file_lines
  lines_count = lines.size
  step = 0

  while step < lines_count
    fields = lines[step].split(',')

    if fields[0] == 'user'
      users << User.new(attributes: parse_user(fields))
      users_count += 1
    else
      browser_name = fields[3].upcase
      user_id = fields[1]

      session = {
        user_id: fields[1],
        session_id: fields[2],
        browser: browser_name,
        time: fields[4].to_i,
        date: fields[5],
      }

      sessions << session
      grouped_sessions[user_id] ||= []
      grouped_sessions[user_id] << session
      browser_names[browser_name] = true
      sessions_count += 1
    end

    step += 1
  end

  {
    users: users,
    users_count: users_count,
    sessions: sessions,
    grouped_sessions: grouped_sessions,
    sessions_count: sessions_count,
    browser_names: browser_names.keys.sort
  }
end

def parse_user(fields)
  {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
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
# Подсчёт количества уникальных браузеров
def work
  parsed_info = users_sessions

  report = {}

  report['totalUsers'] = parsed_info[:users_count]
  report['uniqueBrowsersCount'] = parsed_info[:browser_names].count
  report['totalSessions'] = parsed_info[:sessions_count]
  report['allBrowsers'] = parsed_info[:browser_names].join(',')
  report['usersStats'] = {}

  step = 0
  while step < parsed_info[:users_count]
    user = parsed_info[:users][step]

    session_time = 0
    session_time_max = 0
    browser_names = []
    used_ie = false
    used_chrome = true
    dates = []

    user.add_sessions(parsed_info[:grouped_sessions][user.attributes['id']])
    sessions_count = user.sessions.size
    session_step = 0

    while session_step < sessions_count
      session = user.sessions[session_step]

      session_time += session[:time]
      session_time_max = session[:time] if session_time_max < session[:time]
      browser_names << session[:browser]

      used_ie = true if !used_ie && session[:browser] =~ /INTERNET EXPLORER/
      used_chrome = false if used_chrome && session[:browser] != ~/CHROME/

      dates << session[:date]

      session_step += 1
    end

    report['usersStats'][user.fullname] = {
      'sessionsCount' => user.sessions.count, # Собираем количество сессий по пользователям
      'totalTime' => "#{session_time} min.", # Собираем количество времени по пользователям
      'longestSession' => "#{session_time_max} min.", # Выбираем самую длинную сессию пользователя
      'browsers' => browser_names.sort.join(', '), # Браузеры пользователя через запятую
      'usedIE' => used_ie, # Хоть раз использовал IE?
      'alwaysUsedChrome' => used_chrome, # Всегда использовал только Chrome?
      'dates' => dates.sort.reverse # Даты сессий через запятую в обратном порядке в формате iso8601
    }

    step += 1
  end

  File.write('result.json', "#{report.to_json}\n")
end

work
