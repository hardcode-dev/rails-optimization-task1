# frozen_string_literal: true

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

def collect_stats_from_users(report, users_objects)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key].update(yield(user))
  end
end

def work(filename = '', disable_gc: false)
  disable_gc = ENV['DISABLE_GC']&.casecmp?('true') || disable_gc
  pp "Start work filename=#{filename} disable_gc=#{disable_gc}"
  GC.disable if disable_gc
  file_lines = File.read(ENV['DATA_FILE'] || filename).split("\n")

  users = []
  sessions = []

  file_lines.each do |line|
    cols = line.split(',')
    case cols[0]
    when 'user'
      users << parse_user(line.split(','))
    when 'session'
      sessions << parse_session(line.split(','))
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
  unique_browsers = []
  sessions.each do |session|
    browser = session['browser']

    # uniqueBrowsers += [browser] if uniqueBrowsers.all? { |b| b != browser }
    unique_browsers << browser unless unique_browsers.include?(browser)
  end

  report['uniqueBrowsersCount'] = unique_browsers.count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] =
    sessions
    .map { |s| s['browser'].upcase }
    .sort
    .uniq
    .join(',')

  # Статистика по пользователям
  users_objects = []

  # progressbar = ProgressBar.create(
  #   total: report[:totalUsers],
  #   format: '%a, %J, %E %B' # elapsed time, percent complete, estimate, bar
  #   # output: File.open(File::NULL, 'w') # IN TEST ENV
  # )

  # Преобразовываю массив сессий в хэш-таблицу по 'user_id'
  sessions_by_user_id = sessions.group_by { |session| session['user_id'] }

  users.each do |user|
    attributes = user

    # user_sessions = sessions.select { |session| session['user_id'] = }
    # Ищу из созданного хеша
    user_sessions = sessions_by_user_id[user['id']] || []

    user_object = User.new(attributes:, sessions: user_sessions)
    users_objects << user_object

    # progressbar.increment
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
    { 'longestSession' => user.sessions.map { |s| s['time'].to_i }.max.to_s + ' min.' }
  end

  # Браузеры пользователя через запятую
  collect_stats_from_users(report, users_objects) do |user|
    { 'browsers' => user.sessions.map { |s| s['browser'].upcase }.sort.join(', ') }
  end

  # Хоть раз использовал IE?
  collect_stats_from_users(report, users_objects) do |user|
    { 'usedIE' => user.sessions.any? { |s| s['browser'].upcase.include?('INTERNET EXPLORER') } }
  end

  # Всегда использовал только Chrome?
  collect_stats_from_users(report, users_objects) do |user|
    { 'alwaysUsedChrome' => user.sessions.all? { |s| s['browser'].upcase.include?('CHROME') } }
  end

  # Даты сессий через запятую в обратном порядке в формате iso8601
  collect_stats_from_users(report, users_objects) do |user|
    { 'dates' => user.sessions.map { |s| s['date'] }.sort.reverse }
  end

  File.write('result.json', "#{report.to_json}\n")
  pp 'Finish work'
end
