# Deoptimized version of homework task

require 'json'
require 'byebug'
require 'date'
require 'set'
require 'benchmark'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_user(fields)
  {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4]
  }
end

def parse_session(fields)
  {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5]
  }
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
  end
end

def work(filename, disable_gc = false)
  GC.disable if disable_gc

  file_lines = File.read(filename).split("\n")

  users = []
  sessions = []
  sessions_by_user_id = {}
  users_count = 0
  sessions_count = 0

  file_lines.each do |line|
    cols = line.split(',')

    if cols[0] == 'user'
      users_count += 1
      users << parse_user(cols)
    end

    next unless cols[0] == 'session'

    sessions_count += 1
    parsed_session = parse_session(cols)
    sessions << parsed_session

    user_id = parsed_session['user_id']
    sessions_by_user_id[user_id] ||= []
    sessions_by_user_id[user_id] << parsed_session
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
  unique_browsers = Set.new
  unique_browsers_count = 0

  sessions.each do |session|
    unique_browsers_count += 1 if unique_browsers.add?(session['browser'].upcase)
  end

  report = {
    totalUsers: users_count,
    uniqueBrowsersCount: unique_browsers_count,
    totalSessions: sessions_count,
    allBrowsers: unique_browsers.sort.join(',')
  }

  # Статистика по пользователям
  users_objects = []

  users.each do |user|
    attributes = user
    user_sessions = sessions_by_user_id[user['id']] || []
    user_object = User.new(attributes: attributes, sessions: user_sessions)
    users_objects += [user_object]
  end

  report['usersStats'] = {}

  # Собираем количество сессий по пользователям
  collect_stats_from_users(report, users_objects) do |user|
    { 'sessionsCount' => user.sessions.count }
  end

  # Собираем количество времени по пользователям
  collect_stats_from_users(report, users_objects) do |user|
    { 'totalTime' => user.sessions.sum { |s| s['time'].to_i }.to_s + ' min.' }
  end

  # Выбираем самую длинную сессию пользователя
  collect_stats_from_users(report, users_objects) do |user|
    { 'longestSession' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.' }
  end

  # Браузеры пользователя через запятую
  collect_stats_from_users(report, users_objects) do |user|
    { 'browsers' => user.sessions.map { |s| s['browser'].upcase }.sort.join(', ') }
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
  collect_stats_from_users(report, users_objects) do |user|
    { 'dates' => user.sessions.map { |s| s['date'] }.sort.reverse }
  end

  File.write('result.json', "#{report.to_json}\n")
end

# puts(Benchmark.realtime { work(ENV['DATA_FILE'] || 'data.txt') })
