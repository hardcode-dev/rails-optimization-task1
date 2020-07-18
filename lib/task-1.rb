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
  fields = user.split(',')

  {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

def parse_session(session)
  fields = session.split(',')

  {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5],
  }
end

def collect_stats_from_users(report, user)
  report['usersStats'] ||= {}

  user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"
  report['usersStats'][user_key] ||= {}

  session_times = []
  session_browsers = []
  session_dates = []

  use_ie = false
  all_times_use_chrome = true
  user_sessions_cn = 0

  user.sessions.each do |session|
    browser = session['browser'].upcase
    session_times << session['time'].to_i
    session_browsers << browser

    if use_ie == false && browser =~ /INTERNET EXPLORER/
      use_ie = true
    end

    all_times_use_chrome = false unless browser =~ /CHROME/

    session_dates << session['date']
    user_sessions_cn += 1
  end

  # Собираем количество сессий по пользователям
  report['usersStats'][user_key]['sessionsCount'] = user_sessions_cn

  # Собираем количество времени по пользователям
  report['usersStats'][user_key]['totalTime'] = "#{session_times.sum.to_s} min."

  # Выбираем самую длинную сессию пользователя
  report['usersStats'][user_key]['longestSession'] = "#{session_times.max.to_s} min."

  # Браузеры пользователя через запятую
  report['usersStats'][user_key]['browsers'] = session_browsers.sort.join(', ')

  # Хоть раз использовал IE?
  report['usersStats'][user_key]['usedIE'] = use_ie

  # Всегда использовал только Chrome?
  report['usersStats'][user_key]['alwaysUsedChrome'] = all_times_use_chrome

  # Даты сессий через запятую в обратном порядке в формате iso8601
  report['usersStats'][user_key]['dates'] = session_dates.sort.reverse

  report
end

# Статистика по пользователю
def report_user(user_attributes, report)
  sessions = user_attributes.delete('sessions')
  user_object = User.new(attributes: user_attributes, sessions: sessions)

  collect_stats_from_users(report, user_object)
end

def work(file_path = 'data.txt')
  file_lines = File.read(file_path).split("\n")

  # Используем users в качестве Hash, дабы чтобы в нем можно было в нем хранить не только аттрибуты, но и также сессии
  users = {}

  # Во время перебора строк сразу же собираем браузеры
  hash_unique_browsers = {}

  # А также подсчитываем кол-во сессий
  sessions_count = 0
  users_count = 0
  report = {}

  old_user_id = nil
  file_lines.each do |line|
    if line.start_with?('user')
      if old_user_id
        # Статистика по пользователю
        report = report_user(users[old_user_id], report)

        # Убиваем ненужного юзера
        users.delete(old_user_id)
      end

      user_attributes = parse_user(line)
      users[user_attributes['id']] = user_attributes
      old_user_id = user_attributes['id']

      users_count += 1
    else
      session_attributes = parse_session(line)
      # нужному юзеру присваиваем сессии

      users[session_attributes['user_id']]['sessions'] ||= []
      users[session_attributes['user_id']]['sessions'] << session_attributes

      browser = session_attributes['browser'].upcase
      # собираем все браузеры
      hash_unique_browsers[browser] = true unless hash_unique_browsers.has_key?(browser)

      # иттерируем сессии
      sessions_count += 1
    end
  end

  # Собираем статистику по последнему юзеру
  report = report_user(users[old_user_id], report)

  unique_browsers = hash_unique_browsers.keys

  # Мержим, для того, чтобы сохранить изначальный порядок хеша (json)
  report = {
    totalUsers: users_count,
    uniqueBrowsersCount: unique_browsers.count,
    totalSessions: sessions_count,
    allBrowsers: unique_browsers.sort.join(',')
  }.merge!(report)

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

  File.write('result.json', "#{report.to_json}\n")
end
