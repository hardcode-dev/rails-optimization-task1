# Deoptimized version of homework task

require 'oj'
require 'pry'
require 'date'
require 'minitest/autorun'
require 'benchmark'
require 'byebug'
require 'ruby-progressbar'

class User
  attr_reader :attributes, :sessions
  attr_writer :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_user(fields)
  User.new(attributes: {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
    'sessions' => [],
  }, sessions: [])
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

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
    report['usersStats'][user_key] = block.call(user)
  end
end

def work(file = 'data_large.txt', disable_gc = false, lines = nil)
  GC.disable if disable_gc

  file_lines = File.read(file).split("\n")
  file_lines = file_lines.first(lines) if lines

  # progressbar = ProgressBar.create(
  #   total: file_lines.size,
  #   format: '%a, %J, %E %B' # elapsed time, percent complete, estimate, bar
  #   # output: File.open(File::NULL, 'w') # IN TEST ENV
  # )

  users_objects = []
  sessions = []

  file_lines.each do |line|
    cols = line.split(',')
    user_id = cols[1].to_i

    users_objects[user_id] = parse_user(cols) if cols[0] == 'user'

    if cols[0] == 'session'
      session = parse_session(cols) 
      users_objects[user_id].sessions << session
      sessions << session
    end

    # progressbar.increment
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

  uniq_browsers = sessions.map { |s| s['browser'] }.uniq

  report['uniqueBrowsersCount'] = uniq_browsers.count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] = uniq_browsers.sort.join(',')

  report['usersStats'] = {}

  collect_stats_from_users(report, users_objects) do |user|
    sessions_time = []
    browsers = []
    dates = []

    user.sessions.each do |s|
      sessions_time << s['time']
      browsers << s['browser']
      dates << s['date']
    end

    always_chrome = browsers.all? { |b| b.start_with?('CHROME') }

    {
      # Собираем количество сессий по пользователям
      'sessionsCount' => user.sessions.count,

      # Собираем количество времени по пользователям
      'totalTime' => sessions_time.sum.to_s + ' min.',

      # Выбираем самую длинную сессию пользователя
      'longestSession' => sessions_time.max.to_s + ' min.',

      # Браузеры пользователя через запятую
      'browsers' => browsers.sort.join(', '),

      # Хоть раз использовал IE?
      'usedIE' => always_chrome ? false : browsers.any? { |b| b.start_with?('INTERNET EXPLORER') },

      # Всегда использовал только Chrome?
      'alwaysUsedChrome' => always_chrome,

      # Даты сессий через запятую в обратном порядке в формате iso8601
      'dates' => dates.sort.reverse,
    }
  end

  File.write('result.json', "#{Oj.dump(report, mode: :strict)}\n")
end
