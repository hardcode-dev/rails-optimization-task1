# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_user(user)
  fields = user.split(',')
  parsed_result = {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

def parse_session(session)
  fields = session.split(',')
  parsed_result = {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5],
  }
end

def collect_stats_from_users(report, users_objects)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
    user_stats = report['usersStats'][user_key] ||= {
      # Собираем количество сессий по пользователям
      'sessionsCount' => user.sessions.count,
    }
    total_time = 0
    longest_session = 0
    browsers = []
    used_ie = false
    always_used_chrome = true
    user.sessions.each do |session|
      session_time = session['time'].to_i
      total_time += session_time
      longest_session = session_time if session_time > longest_session
      browsers << (browser = session['browser'].upcase)
      used_ie ||= !!(browser =~ /INTERNET EXPLORER/)
      always_used_chrome = !!(browser =~ /CHROME/) if always_used_chrome
    end
    # Собираем количество времени по пользователям
    user_stats['totalTime'] = "#{total_time} min."
    # Выбираем самую длинную сессию пользователя
    user_stats['longestSession'] = "#{longest_session} min."
    # Браузеры пользователя через запятую
    user_stats['browsers'] = browsers.sort.join(', ')
    # Хоть раз использовал IE?
    user_stats['usedIE'] = used_ie
    # Всегда использовал только Chrome?
    user_stats['alwaysUsedChrome'] = always_used_chrome
    # Даты сессий через запятую в обратном порядке в формате iso8601
    user_stats['dates'] = user.sessions.map{|s| Date.strptime(s['date'], '%Y-%m-%d')}.sort.reverse.map { |d| d.iso8601 }
  end
end

def work(file_name = 'data.txt')
  file_lines = File.read(file_name).split("\n")

  users = []
  sessions = []

  file_lines.each do |line|
    cols = line.split(',')
    users << parse_user(line) if cols[0] == 'user'
    sessions << parse_session(line) if cols[0] == 'session'
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
  uniqueBrowsers = Set.new
  sessions.each do |session|
    browser = session['browser']
    uniqueBrowsers << browser
  end

  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] =
    sessions
      .map { |s| s['browser'] }
      .map { |b| b.upcase }
      .sort
      .uniq
      .join(',')

  # Статистика по пользователям
  users_objects = []

  grouped_sessions = sessions.group_by { |s| s['user_id'] }

  users.each do |user|
    attributes = user
    user_sessions = grouped_sessions[user['id']]
    user_object = User.new(attributes: attributes, sessions: user_sessions)
    users_objects << user_object
  end

  report['usersStats'] = {}

  collect_stats_from_users(report, users_objects)

  File.write('result.json', "#{report.to_json}\n")
end
