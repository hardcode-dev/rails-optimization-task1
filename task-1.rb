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

def collect_stats_from_users(report, users_objects)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
    report['usersStats'][user_key] = evaluate_stats(user)
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

def evaluate_stats(user)
  sessions = user.sessions
  time = sessions.map {|s| s['time']}.map {|t| t.to_i}
  browsers = sessions.map {|s| s['browser']}
  dates = sessions.map{|s| s['date']}
  {
    'sessionsCount' => sessions.count,
    'totalTime' => time.sum.to_s + ' min.',
    'longestSession' => time.max.to_s + ' min.',
    'browsers' => browsers.map {|b| b.upcase}.sort.join(', '),
    'usedIE' => browsers.any? { |b| b.upcase =~ /INTERNET EXPLORER/ },
    'alwaysUsedChrome' => browsers.all? { |b| b.upcase =~ /CHROME/ },
    'dates' => dates.sort
                    .reverse
                    .map do |date|
                      date_ary = date.split('-')
                      Date.new(date_ary[0].to_i, date_ary[1].to_i, date_ary[2].to_i).iso8601
                    end
  }
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

  collect_stats_from_users(report, users_objects)

  File.write('result.json', "#{report.to_json}\n")
end
