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
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5],
  }
end

def collect_stats_from_users(report, users_objects)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= {}

    # Заранее вычисленные данные
    sessions_time_to_i = user.sessions.map { |s| s['time'].to_i }
    sessions_browsers_upcase = user.sessions.map { |s| s['browser'].upcase }

    # Собираем количество сессий по пользователям
    report['usersStats'][user_key]['sessionsCount'] = user.sessions.count
    # Собираем количество времени по пользователям
    report['usersStats'][user_key]['totalTime'] = sessions_time_to_i.sum.to_s + ' min.'
    # Выбираем самую длинную сессию пользователя
    report['usersStats'][user_key]['longestSession'] = sessions_time_to_i.max.to_s + ' min.'
    # Браузеры пользователя через запятую
    report['usersStats'][user_key]['browsers'] = sessions_browsers_upcase.sort.join(', ')
    # Хоть раз использовал IE?
    report['usersStats'][user_key]['usedIE'] = sessions_browsers_upcase.any? { |b| b =~ /INTERNET EXPLORER/ }
    # Всегда использовал только Chrome?
    report['usersStats'][user_key]['alwaysUsedChrome'] = !sessions_browsers_upcase.any? { |b| (b =~ /CHROME/).nil? }
    # Даты сессий через запятую в обратном порядке в формате iso8601
    report['usersStats'][user_key]['dates'] = user.sessions.map { |s| Date.strptime(s['date'], '%Y-%m-%d') }.sort.reverse.map { |d| d.iso8601 }
  end
end

def work(filename: 'data.txt', disable_gc: true)
  users = []
  sessions = []

  File.readlines(filename).each do |line|
    cols = line.split(',')
    case cols[0]
      when 'user' then users.unshift(parse_user(cols))
      when 'session' then sessions.unshift(parse_session(cols))
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

  uniqueBrowsers = sessions.map { |s| s['browser'] }.uniq

  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] =
    sessions
      .map { |s| s['browser'].upcase }
      .sort
      .uniq
      .join(',')

  # Статистика по пользователям
  users_objects = []

  grouped_sessions = sessions.group_by { |session| session['user_id'] }

  users.each do |attributes|
    users_objects.unshift(User.new(attributes: attributes, sessions: grouped_sessions[attributes['id']]))
  end

  report['usersStats'] = {}

  collect_stats_from_users(report, users_objects)

  File.write('result.json', "#{report.to_json}\n")
end
