require 'json'
# require 'pry'
require 'date'

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
    'time' => fields[4],
    'date' => fields[5],
  }
end

def work(input_file)
  users = {}
  sessions = {}

  File.open(input_file).each do |line|
    cols = line.split(',')

    if cols[0] == 'user'
      user = parse_user(cols)
      users[user['id']] = user
    else
      session = parse_session(cols)
      sessions[session['user_id']] ||= {}
      sessions[session['user_id']][session['session_id']] = session
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

  # Подсчёт количества уникальных браузеров
  uniqueBrowsers = {}
  sessions.each do |user_id, user_sessions|
    user_sessions.each do |session_id, session|
      browser = session['browser']
      uniqueBrowsers[session['browser']] = nil
    end
  end
  uniqueBrowsers = uniqueBrowsers.keys

  report['uniqueBrowsersCount'] = uniqueBrowsers.count
  report['totalSessions'] = sessions.map { |k, s| s.count }.sum

  all_browsers = {}
  sessions.each do |user_id, user_sessions|
    user_sessions.each { |_k, user_session| all_browsers[user_session['browser']] = nil }
  end
  
  report['allBrowsers'] = all_browsers.keys.sort.join(',')

  report['usersStats'] = {}

  sessions.each do |user_id, user_sessions|
    user = users[user_id]
    user_key = "#{user['first_name']}" + ' ' + "#{user['last_name']}"

    report['usersStats'][user_key] = { 
      'sessionsCount' => user_sessions.count,
      'totalTime' => user_sessions.map { |_, s| s['time'].to_i}.sum.to_s + ' min.',
      'longestSession' => user_sessions.map {|_, s| s['time'].to_i}.max.to_s + ' min.',
      'browsers' => user_sessions.map {|_, s| s['browser']}.sort.join(', '),
      'usedIE' => user_sessions.any?{|_, s| s['browser'].start_with?("INTERNET EXPLORER")},
      'alwaysUsedChrome' => user_sessions.all?{|_, s| s['browser'].start_with?("CHROME")},
      'dates' => user_sessions.map{|_, s| Date.strptime(s['date'], '%Y-%m-%d')}.sort.reverse.map { |d| d.iso8601 }
    }
  end

  File.write('result.json', JSON.pretty_generate(report))
  report.to_json
end