# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'ruby-progressbar'

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

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
  end
end

# def select_sessions_for_user(sessions, user)
#   sessions.select { |session| session['user_id'] == user['id'] }
# end
#
# def calculate_unique_browsers(sessions)
#   uniqueBrowsers = {}
#   sessions.each do |session|
#     browser = session['browser']
#     uniqueBrowsers[browser] = true
#   end
#   uniqueBrowsers
# end
#
def collect_dates(report, users_objects)
  collect_stats_from_users(report, users_objects) do |user|
    # { 'dates' => user.sessions.map{|s| s['date']}.map {|d| Date.parse(d)}.sort.reverse.map { |d| d.iso8601 } }
    { 'dates' => user.sessions.map { |s| s['date'].strip }.sort.reverse }
  end
end

def collect_stats(report, users_objects)
  # Собираем количество сессий по пользователям
  collect_stats_from_users(report, users_objects) do |user|
    { 'sessionsCount' => user.sessions.count }
  end

  # Собираем количество времени по пользователям
  collect_stats_from_users(report, users_objects) do |user|
    { 'totalTime' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.' }
  end

  # Выбираем самую длинную сессию пользователя
  collect_stats_from_users(report, users_objects) do |user|
    { 'longestSession' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.' }
  end

  # Браузеры пользователя через запятую
  collect_stats_from_users(report, users_objects) do |user|
    { 'browsers' => user.sessions.map {|s| s['browser']}.map {|b| b.upcase}.sort.join(', ') }
  end

  # Хоть раз использовал IE?
  collect_stats_from_users(report, users_objects) do |user|
    { 'usedIE' => user.sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ } }
  end

  # Всегда использовал только Chrome?
  collect_stats_from_users(report, users_objects) do |user|
    { 'alwaysUsedChrome' => user.sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ } }
  end

  # Даты сессий через запятую в обратном порядке в формате iso8601
  collect_dates(report, users_objects)
end

def write_report_to_file(report)
  File.write('result.json', "#{report.to_json}\n")
end

def prepare_users_objects(users, sessions_by_user)
  users_objects = []

  users.each do |user|
    attributes = user
    user_sessions = sessions_by_user[user['id']]
    user_object = User.new(attributes: attributes, sessions: user_sessions)
    users_objects = users_objects + [user_object]
  end
  users_objects 
end

def parse_session_line(line, sessions, sessions_by_user, unique_browsers)
  session = parse_session(line)
  sessions_by_user[session['user_id']] ||= []
  sessions_by_user[session['user_id']] << session
  unique_browsers[session['browser']] = true

  session
end

def read_file(filename)
  line_count = `wc -l "#{filename}"`.strip.split(' ')[0].to_i

  progressbar = ProgressBar.create(
    total: line_count,
    format: '%a, %J, %E %B' # elapsed time, % complete, estimate, bar
  )

  users = []
  sessions = []
  sessions_by_user = {}
  unique_browsers = {}

  File.foreach(filename) do |line|
    cols = line.split(',')

    if cols[0] == 'user'
      users << parse_user(line)
    end

    if cols[0] == 'session'
      sessions << parse_session_line(line, sessions, sessions_by_user, unique_browsers)
    end

    # progressbar.increment
  end

  [users, sessions, sessions_by_user, unique_browsers]
end

def work(filename)
  users, sessions, sessions_by_user, unique_browsers = read_file(filename)

  # Подсчёт количества уникальных браузеров
  unique_browsers_count = unique_browsers.keys.count

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

  report['uniqueBrowsersCount'] = unique_browsers_count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] =
    sessions
      .map { |s| s['browser'] }
      .map { |b| b.upcase }
      .sort
      .uniq
      .join(',')

  # Статистика по пользователям
  users_objects = prepare_users_objects(users, sessions_by_user)

  report['usersStats'] = {}

  collect_stats(report, users_objects)

  write_report_to_file(report)

  puts "Done. Processed file #{filename}."
end

# work('data/data_large.txt')

