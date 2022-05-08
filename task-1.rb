# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'oj'
require 'ruby-progressbar'

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
    'age' => fields[4]
  }
end

def parse_session(fields)
  {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5]
  }
end

def collect_stats_from_users(report, users_objects, &block)
end

# def select_sessions_for_user(sessions, user)
#   sessions.select { |session| session['user_id'] == user['id'] }
# end
#
# def calculate_unique_browsers(sessions)
#   uniqueBrowsers = {}
#   sessions.each do |session|
#     browser = session['browser']
#     uniqueBrowsers[browser] = true
#   end
#   uniqueBrowsers
# end
#

def collect_stats(report, users, sessions_by_user)
  users_objects = []

  users.each do |user|
    attributes = user
    user_sessions = sessions_by_user[user['id']] || []

    user_key = "#{attributes['first_name']}" + ' ' + "#{attributes['last_name']}"

    times = []
    browsers = []
    dates = []

    user_sessions.each do |session|
      times << session['time'].to_i
      browsers << session['browser'].upcase
      dates << session['date'].strip
    end

    data = {
      # Собираем количество сессий по пользователям
      'sessionsCount' => user_sessions.count,
      # Собираем количество времени по пользователям
      'totalTime' => times.sum.to_s + ' min.',
      # Выбираем самую длинную сессию пользователя
      'longestSession' => times.max.to_s + ' min.',
      # Браузеры пользователя через запятую
      'browsers' => browsers.sort.join(', '),
      # Хоть раз использовал IE?
      'usedIE' => browsers.any? { |b| b =~ /INTERNET EXPLORER/ },
      # Всегда использовал только Chrome?
      'alwaysUsedChrome' => browsers.all? { |b| b =~ /CHROME/ },
      # Даты сессий через запятую в обратном порядке в формате iso8601
      'dates' => dates.sort.reverse
    }

    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(data)
  end
end

def write_report_to_file(report)
  Oj.mimic_JSON
  File.write('result.json', "#{Oj.dump(report)}\n")
end

def prepare_users_objects(users, sessions_by_user)
end

def parse_session_line(line, sessions_by_user, unique_browsers)
  session = parse_session(line)

  sessions_by_user[session['user_id']] ||= []
  sessions_by_user[session['user_id']] << session
  unique_browsers[session['browser']] = true
end

def read_file(filename)
  line_count = `wc -l "#{filename}"`.strip.split(' ')[0].to_i

  progressbar = ProgressBar.create(
    total: line_count,
    format: '%a, %J, %E %B' # elapsed time, % complete, estimate, bar
  )

  users = []
  sessions_count = 0
  sessions_by_user = {}
  unique_browsers = {}

  File.foreach(filename) do |line|
    cols = line.split(',')

    if cols[0] == 'user'
      users << parse_user(cols)
    end

    if cols[0] == 'session'
      sessions_count += 1
      parse_session_line(cols, sessions_by_user, unique_browsers)
    end

    # progressbar.increment
  end

  [users, sessions_count, sessions_by_user, unique_browsers.keys]
end

def work(filename)
  users, sessions_count, sessions_by_user, unique_browsers = read_file(filename)

  # Подсчёт количества уникальных браузеров
  unique_browsers_count = unique_browsers.count

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

  report['uniqueBrowsersCount'] = unique_browsers_count

  report['totalSessions'] = sessions_count

  report['allBrowsers'] =
    unique_browsers
      .map { |b| b.upcase }
      .sort
      .join(',')

  report['usersStats'] = {}

  collect_stats(report, users, sessions_by_user)

  write_report_to_file(report)

  puts "Done. Processed file #{filename}."
end

# work('data/data_large.txt')

