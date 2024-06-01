# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'set'

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
  user_id = fields[1]
  parsed_result = {
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5],
  }
  {uid: user_id, session: parsed_result}
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
  end
end

# Статистика по пользователям
def create_objects_from_users(users_ary, uid_to_sessions)
  users_objects = []
  users_ary.each do |user|
    attributes = user
    user_sessions = uid_to_sessions[user['id']]
    user_object = User.new(attributes: attributes, sessions: user_sessions)
    users_objects.concat([user_object])
  end

  users_objects
end

def sessions_num_by_users(report, users_objects)
  # Собираем количество сессий по пользователям
  collect_stats_from_users(report, users_objects) do |user|
    { 'sessionsCount' => user.sessions&.count || 0 }
  end
end

def amount_of_time_by_users(report, users_objects)
  # Собираем количество времени по пользователям
  collect_stats_from_users(report, users_objects) do |user|
    { 'totalTime' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.' }
  end
end

def longest_user_session(report, users_objects)
  # Выбираем самую длинную сессию пользователя
  collect_stats_from_users(report, users_objects) do |user|
    { 'longestSession' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.' }
  end
end

def user_browsers(report, users_objects)
  # Браузеры пользователя через запятую
  collect_stats_from_users(report, users_objects) do |user|
    { 'browsers' => user.sessions.map {|s| s['browser']}.map {|b| b.upcase}.sort.join(', ') }
  end
end

def any_ie_browser(report, users_objects)
  # Хоть раз использовал IE?
  collect_stats_from_users(report, users_objects) do |user|
    { 'usedIE' => user.sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ } }
  end
end

def always_chrome_browser(report, users_objects)
  # Всегда использовал только Chrome?
  collect_stats_from_users(report, users_objects) do |user|
    { 'alwaysUsedChrome' => user.sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ } }
  end
end

def sessions_dates(report, users_objects)
  # Даты сессий через запятую в обратном порядке в формате iso8601
  collect_stats_from_users(report, users_objects) do |user|
    { 'dates' => user.sessions
                     .map{|s| s['date']}
                     .sort
                     .reverse
                     .map do |date|
                        date_ary = date.split('-')
                        Date.new(date_ary[0].to_i, date_ary[1].to_i, date_ary[2].to_i).iso8601
                     end
    }
  end
end

def parse_to_users_and_sessions(file_lines, users, sessions, uid_to_sessions)
  file_lines.each do |line|
    cols = line.split(',')
    users.concat([parse_user(line)]) if cols[0] == 'user'
    if cols[0] == 'session'
      parsed_session = parse_session(line)
      sessions.concat([parsed_session[:session]])
      uid = parsed_session[:uid]
      uid_to_sessions[uid] ||= []
      uid_to_sessions[uid].concat([parsed_session[:session]])
    end
  end
end

def work
  if ARGV[0]&.start_with? 'filename='
    filename = ARGV[0].split('=')[1]
  else
    filename = 'data.txt'
  end

  file_lines = File.read(filename).split("\n")

  users = []
  sessions = []
  uid_to_sessions = {}

  parse_to_users_and_sessions(file_lines, users, sessions, uid_to_sessions)

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
  unique_browsers = Set.new
  sessions.each do |session|
    browser = session['browser']
    unique_browsers << browser
  end

  report['uniqueBrowsersCount'] = unique_browsers.size

  report['totalSessions'] = sessions.count

  report['allBrowsers'] =
    sessions
      .map { |s| s['browser'] }
      .map { |b| b.upcase }
      .sort
      .uniq
      .join(',')

  users_objects = create_objects_from_users(users, uid_to_sessions)

  report['usersStats'] = {}

  sessions_num_by_users(report, users_objects)
  amount_of_time_by_users(report, users_objects)
  longest_user_session(report, users_objects)
  user_browsers(report, users_objects)
  any_ie_browser(report, users_objects)
  always_chrome_browser(report, users_objects)
  sessions_dates(report, users_objects)

  File.write('result.json', "#{report.to_json}\n")
end
