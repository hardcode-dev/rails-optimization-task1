# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'byebug'

DATA_FILE = 'data_samples/data.txt'.freeze
LARGE_DATA_FILE = 'data_samples/data_large.txt'.freeze
RESULT_JSON_FILE = 'result.json'.freeze

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_user(user)
  fields = user.split(',')
  {
    id: fields[1],
    first_name: fields[2],
    last_name: fields[3],
    age: fields[4],
  }
end

def parse_session(session)
  fields = session.split(',')
  {
    user_id: fields[1],
    session_id: fields[2],
    browser: fields[3],
    time: fields[4],
    date: fields[5],
  }
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes[:first_name]} #{user.attributes[:last_name]}"
    report[:usersStats][user_key] ||= {}
    report[:usersStats][user_key] = report[:usersStats][user_key].merge(block.call(user))
  end
end

def work(file_path: DATA_FILE)
  users = []
  sessions = []

  IO.foreach(file_path).each do |line|
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
  all_browsers = sessions.map { |s| s[:browser] }.uniq
  report['uniqueBrowsersCount'] = all_browsers.count
  report['totalSessions'] = sessions.count
  report['allBrowsers'] = all_browsers.map(&:upcase).sort.join(',')

  # Статистика по пользователям
  users_objects = []
  users.each do |user|
    user_sessions = sessions.select { |session| session[:user_id] == user[:id] }
    users_objects << User.new(attributes: user, sessions: user_sessions)
  end

  report[:usersStats] = {}
  collect_stats_from_users(report, users_objects) do |user|
    {
      sessionsCount: user.sessions.count,
      totalTime: "#{user.sessions.sum { |s| s[:time].to_i }} min.",
      longestSession: "#{user.sessions.max_by { |s| s[:time].to_i }&.fetch(:time, '0')} min.",
      browsers: user.sessions.map { |s| s[:browser].upcase }.sort.join(', '),
      usedIE: user.sessions.any? { |s| s[:browser] =~ /internet explorer/i },
      alwaysUsedChrome: user.sessions.all? { |s| s[:browser] =~ /chrome/i },
      dates: user.sessions.map { |s| Date.strptime(s[:date], '%Y-%m-%d').to_s }.sort.reverse
    }
  end

  File.write(RESULT_JSON_FILE, "#{report.to_json}\n")
end
