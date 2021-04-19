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
    id: fields[1],
    first_name: fields[2],
    last_name: fields[3],
    age: fields[4],
  }
end

def parse_session(fields)
  {
    user_id: fields[1],
    session_id: fields[2],
    browser: fields[3].upcase,
    time: fields[4],
    date: fields[5],
  }
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes[:first_name]}" + ' ' + "#{user.attributes[:last_name]}"
    report[:usersStats][user_key] ||= {}
    report[:usersStats][user_key] = report[:usersStats][user_key].merge(block.call(user))
  end
end

def work(from_file, to_file)
  file_lines = File.read(from_file).split("\n")

  users = []
  sessions = {uniqueBrowsers: {}, totalSessions: 0}

  file_lines.each do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      users << parse_user(cols)
    else
      session = parse_session(cols)
      user_id = session[:user_id]
      browser = session[:browser]

      sessions[user_id] ||= []
      sessions[user_id] << session
      sessions[:uniqueBrowsers][browser] ||= true
      sessions[:totalSessions] += 1
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

  report[:uniqueBrowsersCount] = sessions[:uniqueBrowsers].keys.count

  report[:totalSessions] = sessions[:totalSessions]

  report[:allBrowsers] =
    sessions[:uniqueBrowsers]
      .keys
      .sort
      .join(',')

  # Статистика по пользователям
  users_objects = []

  users.each do |user|
    attributes = user
    user_sessions = sessions[user[:id]]
    user_object = User.new(attributes: attributes, sessions: user_sessions)
    users_objects = users_objects + [user_object]
  end

  report[:usersStats] = {}

  # Собираем количество сессий по пользователям
  # Собираем количество времени по пользователям
  # Выбираем самую длинную сессию пользователя
  # Браузеры пользователя через запятую
  # Хоть раз использовал IE?
  # Всегда использовал только Chrome?
  collect_stats_from_users(report, users_objects) do |user|
    user_sessions = user.sessions

    if user_sessions
      times = user_sessions.map {|s| s[:time]}&.map {|t| t.to_i}
      browsers = user_sessions.map {|s| s[:browser]}

      { sessionsCount: user_sessions.count,
        totalTime: times.sum.to_s + ' min.',
        longestSession: times.max.to_s + ' min.',
        browsers: browsers.sort.join(', '),
        usedIE: browsers.any? { |b| b.start_with?('INTERNET EXPLORER') },
        alwaysUsedChrome: browsers.all? { |b| b.start_with?('CHROME') },
        dates: user_sessions.map{|s| s[:date]}.sort.reverse }
    else
      {}
    end
  end

  File.write(to_file, "#{report.to_json}\n")
end
