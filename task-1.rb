# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'

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
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5],
  }
end

# Собираем количество сессий по пользователям
# Собираем количество времени по пользователям
# Выбираем самую длинную сессию пользователя
# Браузеры пользователя через запятую
# Хоть раз использовал IE?
# Всегда использовал только Chrome?
# Даты сессий через запятую в обратном порядке в формате iso8601
def collect_stats_from_users(report, user)
  user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"
  time = user.sessions.map { |s| s['time'].to_i }
  browsers = user.sessions.map { |s| s['browser'].upcase }
  dates = user.sessions.map { |s| Date.iso8601(s['date']) }

  report['usersStats'][user_key] = {
    'sessionsCount' => user.sessions.count,
    'totalTime' => "#{time.sum} min.",
    'longestSession' => "#{time.max} min.",
    'browsers' => browsers.sort.join(', '),
    'usedIE' => browsers.any? { |b| /INTERNET EXPLORER/.match?(b) },
    'alwaysUsedChrome' => browsers.all? { |b| /CHROME/.match?(b) },
    'dates' => dates.sort.reverse
  }
end

def work(filename: 'data.txt', gc_disabled: false)
  GC.disable if gc_disabled

  file_lines = File.read(filename).split("\n")

  users = []
  sessions = []

  file_lines.each do |line|
    cols = line.split(',')
    case cols[0]
    when 'user'
      users << parse_user(cols)
    when 'session'
      sessions << parse_session(cols)
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
  uniqueBrowsers = sessions.map{ |session| session['browser'].upcase }.uniq

  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] = uniqueBrowsers.sort.join(',')

  # Статистика по пользователям
  report['usersStats'] = {}

  sessions_by_user = sessions.group_by { |s| s['user_id'] }
  users.each do |user|
    user_object = User.new(attributes: user, sessions: sessions_by_user[user['id']])
    collect_stats_from_users(report, user_object)
  end

  File.write('result.json', "#{report.to_json}\n")
end
