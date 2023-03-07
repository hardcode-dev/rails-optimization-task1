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

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
  end
end

def work(input_file)
  file_lines = File.read(input_file).split("\n")


  users = {}
  sessions = {}

  file_lines.each do |line|
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
  users_objects = []

  users.each do |user_id, user|
    attributes = user
    user_sessions = sessions[user_id]
    user_object = User.new(attributes: attributes, sessions: user_sessions)
    users_objects = users_objects + [user_object]
  end

  report['usersStats'] = {}

  # Собираем количество сессий по пользователям
  collect_stats_from_users(report, users_objects) do |user|
    { 'sessionsCount' => user.sessions.count }
  end

  # Собираем количество времени по пользователям
  collect_stats_from_users(report, users_objects) do |user|
    { 'totalTime' => user.sessions.map {|_, s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.' }
  end

  # Выбираем самую длинную сессию пользователя
  collect_stats_from_users(report, users_objects) do |user|
    { 'longestSession' => user.sessions.map {|_, s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.' }
  end

  # Браузеры пользователя через запятую
  collect_stats_from_users(report, users_objects) do |user|
    { 'browsers' => user.sessions.map {|_, s| s['browser']}.map {|b| b.upcase}.sort.join(', ') }
  end

  # Хоть раз использовал IE?
  collect_stats_from_users(report, users_objects) do |user|
    { 'usedIE' => user.sessions.map{|_, s| s['browser']}.any? { |b| b.upcase.start_with?("INTERNET EXPLORER") } }
  end

  # Всегда использовал только Chrome?
  collect_stats_from_users(report, users_objects) do |user|
    { 'alwaysUsedChrome' => user.sessions.map{|_, s| s['browser']}.all? { |b| b.upcase.start_with?("CHROME") } }
  end

  # Даты сессий через запятую в обратном порядке в формате iso8601
  collect_stats_from_users(report, users_objects) do |user|
    { 'dates' => user.sessions.map{|_, s| s['date']}.map {|d| Date.parse(d)}.sort.reverse.map { |d| d.iso8601 } }
  end

  File.write('result.json', JSON.pretty_generate(report))
  report.to_json
end