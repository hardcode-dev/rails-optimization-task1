# optimized version of homework task

require 'date'
require 'minitest/autorun'
require 'ccsv'
require 'oj'
require 'benchmark'
require 'benchmark/ips'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def collect_stats_from_users(report, users_objects)
  users_objects.each { |user| report['usersStats']["#{user.attributes[2]} #{user.attributes[3]}"] = yield(user) }
end

def work(filename = 'data.txt', disable_gc: false)
  disable_gc ? GC.disable : GC.enable

  filename = ENV['DATA_FILE'] || filename
  users = []
  sessions = []

  Ccsv.foreach(filename) do |record|
    case record[0]
    when 'user' then users << record
    when 'session' then sessions << record
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

  # Подсчёт количества уникальных браузеров
  unique_browsers = sessions.group_by { |k| k[3] }.keys

  report = {
    'totalUsers' => users.count,
    'uniqueBrowsersCount' => unique_browsers.count,
    'totalSessions' => sessions.count,
    'allBrowsers' => unique_browsers.sort.join(',').upcase
  }

  # Статистика по пользователям
  users_objects = []

  sessions_by_user = sessions.group_by { |k| k[1] }
  users.each { |user| users_objects << User.new(attributes: user, sessions: sessions_by_user[user[1]] || []) }

  report['usersStats'] = {}
  collect_stats_from_users(report, users_objects) do |user|
    user_time = []
    user_browsers = []
    user_dates = []
    user.sessions.each do |s|
      user_time << s[4].to_i
      user_browsers << s[3].upcase
      user_dates << Date.parse(s[5])
    end
    {
      # Собираем количество сессий по пользователям
      'sessionsCount' => user.sessions.count,
      # Собираем количество времени по пользователям
      'totalTime' => "#{user_time.sum} min.",
      # Выбираем самую длинную сессию пользователя
      'longestSession' => "#{user_time.max} min.",
      # Браузеры пользователя через запятую
      'browsers' => user_browsers.sort.join(', '),
      # Хоть раз использовал IE?
      'usedIE' => user_browsers.any? { |b| b =~ /INTERNET EXPLORER/ },
      # Всегда использовал только Chrome?
      'alwaysUsedChrome' => user_browsers.all? { |b| b =~ /CHROME/ },
      # Даты сессий через запятую в обратном порядке в формате iso8601
      'dates' => user_dates.sort.reverse.map(&:iso8601)
    }
  end

  File.write('result.json', "#{Oj.dump(report)}\n")
end
