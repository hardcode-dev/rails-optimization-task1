# Optimized version of homework task

require 'oj'
require 'pry'

class User
  attr_reader :attributes, :sessions, :times, :browsers, :dates, :full_name

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
    @times = []
    @browsers = []
    @dates = []
    @full_name = "#{attributes['first_name']} #{attributes['last_name']}"
    fill_fields
  end

  def fill_fields
    sessions.each do |session|
      @times << session['time']
      @browsers << session['browser'].upcase
      @dates << session['date']
    end
  end
end

def parse_user(user)
  {
    'id' => user[1],
    'first_name' => user[2],
    'last_name' => user[3],
    'age' => user[4]
  }
end

def parse_session(session)
  {
    'user_id' => session[1],
    'session_id' => session[2],
    'browser' => session[3],
    'time' => session[4].to_i,
    'date' => session[5]
  }
end

def collect_stats_from_users(report, user, &block)
  report['usersStats'][user.full_name] = block.call(user)
end

def work(file_name:, disable_gc: false)
  GC.disable if disable_gc

  file_lines = File.read(file_name).split("\n")

  users = []
  sessions = []

  file_lines.each do |line|
    cols = line.split(',')
    users << parse_user(cols) if cols.first == 'user'
    sessions << parse_session(cols) if cols.first == 'session'
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
  unique_browsers = sessions.map { |s| s['browser'].upcase }.uniq

  report = {
    'totalUsers' => users.size,
    'uniqueBrowsersCount' => unique_browsers.size,
    'totalSessions' => sessions.size,
    'allBrowsers' => unique_browsers.sort.join(','),
    'usersStats' => {}
  }

  session_by_user = sessions.group_by { |s| s['user_id'] }

  users.each do |user|
    user_sessions = session_by_user[user['id']]
    user_object = User.new(attributes: user, sessions: user_sessions)

    collect_stats_from_users(report, user_object) do |user|
      {
        # Собираем количество сессий по пользователям
        'sessionsCount' => user.sessions.size,
        # Собираем количество времени по пользователям
        'totalTime' => "#{user.times.sum} min.",
        # Выбираем самую длинную сессию пользователя
        'longestSession' => "#{user.times.max} min.",
        # Браузеры пользователя через запятую
        'browsers' => user.browsers.sort.join(', '),
        # Хоть раз использовал IE?
        'usedIE' => user.browsers.any? { |b| b.upcase =~ /INTERNET EXPLORER/ },
        # Всегда использовал только Chrome?
        'alwaysUsedChrome' => user.browsers.all? { |b| b.upcase =~ /CHROME/ },
        # Даты сессий через запятую в обратном порядке в формате iso8601
        'dates' => user.dates.sort.reverse
      }
    end
  end

  File.write('result.json', "#{Oj.dump report}\n")
end
