# for profiling with GC.disable

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

def parse_user(fields)
  #fields = user.split(',')
  {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

def parse_session(fields)
  #fields = session.split(',')
  {
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

def work(filename = '', disable_gc: false)
  puts 'Start work'
  GC.disable if disable_gc

  file_lines = File.read(ENV['DATA_FILE'] || filename).split("\n")

  users = file_lines.filter { |line| line.start_with?('user') }.map { |line| parse_user(line) }
  sessions = file_lines.filter { |line| line.start_with?('session') }.map { |line| parse_session(line) }

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
  uniqueBrowsers = sessions.map { |s| s['browser'] }.uniq
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

  sessions_hash = sessions.group_by { |session| session['user_id'] }

  users.each do |user|
    attributes = user
    user_sessions = sessions_hash[user['id']] || []
    user_object = User.new(attributes: attributes, sessions: user_sessions)
    users_objects = users_objects + [user_object]
  end

  report['usersStats'] = {}

  # Определяем методы для разных статистик
  def collect_sessions_count(report, users_objects)
    collect_stats_from_users(report, users_objects) do |user|
      { 'sessionsCount' => user.sessions.count }
    end
  end

  def collect_total_time(report, users_objects)
    collect_stats_from_users(report, users_objects) do |user|
      { 'totalTime' => user.sessions.map { |s| s['time'] }.map(&:to_i).sum.to_s + ' min.' }
    end
  end

  def collect_longest_session(report, users_objects)
    collect_stats_from_users(report, users_objects) do |user|
      { 'longestSession' => user.sessions.map { |s| s['time'] }.map(&:to_i).max.to_s + ' min.' }
    end
  end

  def collect_browsers(report, users_objects)
    collect_stats_from_users(report, users_objects) do |user|
      { 'browsers' => user.sessions.map { |s| s['browser'] }.map(&:upcase).sort.join(', ') }
    end
  end

  def check_used_ie(report, users_objects)
    collect_stats_from_users(report, users_objects) do |user|
      { 'usedIE' => user.sessions.any? { |s| s['browser'].upcase.include?('INTERNET EXPLORER') } }
    end
  end

  def check_always_used_chrome(report, users_objects)
    collect_stats_from_users(report, users_objects) do |user|
      { 'alwaysUsedChrome' => user.sessions.all? { |s| s['browser'].upcase.include?('CHROME') } }
    end
  end

  def collect_session_dates(report, users_objects)
    collect_stats_from_users(report, users_objects) do |user|
    { 'dates' => user.sessions.map { |session| session['date'] }.sort.reverse }
    end
  end

  # Теперь можно вызывать эти методы для сбора статистики
  collect_sessions_count(report, users_objects)
  collect_total_time(report, users_objects)
  collect_longest_session(report, users_objects)
  collect_browsers(report, users_objects)
  check_used_ie(report, users_objects)
  check_always_used_chrome(report, users_objects)
  collect_session_dates(report, users_objects)

  File.write('result.json', "#{report.to_json}\n")
  puts 'Finish work'
end
