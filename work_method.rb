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

  report['allBrowsers'] = uniqueBrowsers.map(&:upcase).sort.join(',')

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

  # Собираем статистику по пользователям
  collect_stats_from_users(report, users_objects) do |user|
    # Собираем количество сессий по пользователям
    sessions_count = user.sessions.count
    
    # Собираем количество времени по пользователям
    total_time = user.sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.'

    # Выбираем самую длинную сессию пользователя
    longest_session = user.sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.'

    # Браузеры пользователя через запятую
    browsers = user.sessions.map {|s| s['browser']}.map {|b| b.upcase}.sort

    # Хоть раз использовал IE?
    used_IE = browsers.any? { |b| b =~ /INTERNET EXPLORER/ }

    # Всегда использовал только Chrome?
    always_used_chrome = browsers.all? { |b| b =~ /CHROME/ }

    # Даты сессий через запятую в обратном порядке в формате iso8601
    dates = user.sessions.map { |session| session['date'] }.sort.reverse

    {
      'sessionsCount' => sessions_count,
      'totalTime' => total_time,
      'longestSession' => longest_session,
      'browsers' => browsers.join(', '),
      'usedIE' => used_IE,
      'alwaysUsedChrome' => always_used_chrome,
      'dates' => dates
    }
  end

  File.write('result.json', "#{report.to_json}\n")
  puts 'Finish work'
end
