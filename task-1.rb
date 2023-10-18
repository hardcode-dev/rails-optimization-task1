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

def parse_user(user)
  {
    'id' => user[1],
    'first_name' => user[2],
    'last_name' => user[3],
    'age' => user[4],
  }
end

def parse_session(session)
  {
    'user_id' => session[1],
    'session_id' => session[2],
    'browser' => session[3],
    'time' => session[4],
    'date' => session[5],
  }
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"
    report['usersStats'][user_key] = block.call(user)
  end
end

def work(filename = 'data_large.txt', disable_gc: false)
  GC.disable if disable_gc

  users = []
  sessions = []

  File.open(filename).each_line do |line|
    cols = line.chomp.split(',')
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
  unique_browsers = sessions.map { |s| s['browser'] }.uniq

  report['uniqueBrowsersCount'] = unique_browsers.count

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

  users_sessions = sessions.group_by { |session| session['user_id'] }

  users_objects = users.map { |user| User.new(attributes: user, sessions: users_sessions[user['id']]) }

  report['usersStats'] = {}

  collect_stats_from_users(report, users_objects) do |user|
    upcased_browsers = []
    sessions_time = []

    user.sessions.each do |s|
      upcased_browsers << s['browser'].upcase
      sessions_time << s['time'].to_i
    end

    {
      'sessionsCount':    user.sessions.count,
      'totalTime':        "#{sessions_time.sum} min.",
      'longestSession':   "#{sessions_time.max} min.",
      'browsers':         upcased_browsers.sort.join(', '),
      'usedIE':           upcased_browsers.any? { |b| b =~ /INTERNET EXPLORER/ },
      'alwaysUsedChrome': upcased_browsers.all? { |b| b =~ /CHROME/ },
      'dates':            user.sessions.map { |s| s['date'] }.sort.reverse
    }
  end

  File.write('result.json', "#{report.to_json}\n")
end
