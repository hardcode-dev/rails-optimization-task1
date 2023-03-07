require 'json'
# require 'pry'
require 'date'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_user(fields)
  parsed_result = {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

def parse_session(fields)
  parsed_result = {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
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
  
  report['allBrowsers'] = all_browsers.keys.map(&:upcase).sort.join(',')

  # Статистика по пользователям
  users_objects = {}

  users.each do |user_id, user|
    attributes = user
    user_sessions = sessions[user_id]
    users_objects[user_id] = User.new(attributes: attributes, sessions: user_sessions)
  end

  report['usersStats'] = {}

  users_objects.each do |user_id, user|
    user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"

    report['usersStats'][user_key] = { 
      'sessionsCount' => user.sessions.count,
      'totalTime' => user.sessions.map { |_, s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.',
      'longestSession' => user.sessions.map {|_, s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.',
      'browsers' => user.sessions.map {|_, s| s['browser']}.map {|b| b.upcase}.sort.join(', '),
      'usedIE' => user.sessions.map{|_, s| s['browser']}.any? { |b| b.upcase.start_with?("INTERNET EXPLORER") },
      'alwaysUsedChrome' => user.sessions.map{|_, s| s['browser']}.all? { |b| b.upcase.start_with?("CHROME") },
      'dates' => user.sessions.map{|_, s| s['date']}.map {|d| Date.strptime(d, '%Y-%m-%d')}.sort.reverse.map { |d| d.iso8601 }
    }
  end

  def convert_date(date)

  end

  File.write('result.json', JSON.pretty_generate(report))
  report.to_json
end