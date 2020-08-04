# Deoptimized version of homework task

require 'date'
require 'pry'
require 'json'

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
    report['usersStats'][user_key] = {
      'sessionsCount' => user.sessions.count,
      'totalTime' => user.sessions.map {|s| s['time'].to_i}.sum.to_s + ' min.',
      'longestSession' => user.sessions.map {|s| s['time'].to_i}.max.to_s + ' min.',
      'browsers' => user.sessions.map {|s| s['browser'].upcase}.sort.join(', '),
      'usedIE' => user.sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ },
      'alwaysUsedChrome' => user.sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ },
      'dates' => user.sessions.map{|s| s['date']}.sort.reverse
    }
  end
end

def work(file, disable_gc: false)
  GC.disable if disable_gc

  file_lines = File.read('data/' + file).split("\n")

  # Статистика по пользователям
  users_objects = []

  file_lines.each do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      user_object = User.new(attributes: parse_user(line), sessions: [])
      users_objects += [user_object]
    end
    users_objects.last.sessions << parse_session(line) if cols[0] == 'session'
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

  report[:totalUsers] = users_objects.count

  # Подсчёт количества уникальных браузеров
  uniqueBrowsers = []
  users_objects.each do |user|
    user.sessions.each do |session|
      browser = session['browser']
      uniqueBrowsers += [browser] unless uniqueBrowsers.include?(browser)
    end
  end

  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = users_objects.sum { |u| u.sessions.count }

  report['allBrowsers'] =
    users_objects.flat_map(&:sessions)
      .map { |s| s['browser'] }
      .map { |b| b.upcase }
      .sort
      .uniq
      .join(',')

  report['usersStats'] = {}

  # Собираем количество времени по пользователям
  collect_stats_from_users(report, users_objects)

  File.write('result.json', "#{report.to_json}\n")
end
