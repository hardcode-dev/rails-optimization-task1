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

def parse_user(fields)
  {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

def parse_session(fields)
  {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3].upcase,
    'time' => fields[4].to_i,
    'date' => fields[5],
  }
end

def collect_stats_from_users(report, users_objects)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
    report['usersStats'][user_key] = yield(user)
  end
end

def work(filepath = 'data.txt')
  user_blocks = File.read(filepath).split('user,')
  user_blocks.delete_at(0)

  users = []
  users_objects = []
  sessions = []

  # Статистика по пользователям
  user_blocks.each do |block|
    user_sessions = []
    block = 'user,' + block
    lines = block.split("\n")
    lines.each do |line|
      cols = line.split(',')
      users = users + [parse_user(cols)] if cols[0] == 'user'
      user_sessions = user_sessions + [parse_session(cols)] if cols[0] == 'session'
    end
    user_object = User.new(attributes: users.last, sessions: user_sessions)
    users_objects = users_objects + [user_object]
    sessions = sessions + user_sessions
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
  uniqueBrowsers = sessions.map{ |x| x['browser'] }.uniq

  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] =
    sessions
      .map { |s| s['browser'] }
      .sort
      .uniq
      .join(',')

  report['usersStats'] = {}

  collect_stats_from_users(report, users_objects) do |user|
    times = user.sessions.map {|s| s['time']}
    browsers = user.sessions.map {|s| s['browser']}
    {
      'sessionsCount' => user.sessions.count, # Собираем количество сессий по пользователям
      'totalTime' => times.sum.to_s + ' min.', # Собираем количество времени по пользователям
      'longestSession' => times.max.to_s + ' min.', # Выбираем самую длинную сессию пользователя
      'browsers' => browsers.sort.join(', '), # Браузеры пользователя через запятую
      'usedIE' => browsers.any? { |b| b =~ /INTERNET EXPLORER/ }, # Хоть раз использовал IE?
      'alwaysUsedChrome' => browsers.all? { |b| b =~ /CHROME/ }, # Всегда использовал только Chrome?
      'dates' => user.sessions.map{|s| s['date']}.sort.reverse # Даты сессий через запятую в обратном порядке в формате iso8601
    }
  end

  File.write('result.json', "#{report.to_json}\n")
end
