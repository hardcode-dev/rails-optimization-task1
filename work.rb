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
  parsed_result = {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

def parse_session(fields)
  parsed_result = {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5],
  }
end

def work(data_file_path, result_file_path = 'result.json')
  file_lines = File.read(data_file_path).split("\n")

  users_objects = []
  sessions = []
  uniqueBrowsers = Set.new
  totalSessions = 0
  last_user_object = nil

  file_lines.each do |line|
    cols = line.split(',')
    case cols[0]
    when 'user'
      last_user_object = User.new(attributes: parse_user(cols), sessions: [])
      users_objects << last_user_object
    when 'session'
      session = parse_session(cols)
      last_user_object.sessions << session
      totalSessions += 1
      uniqueBrowsers.add(session['browser'].upcase)
    end
  end

  sessions_by_users = sessions.group_by { |session| session['user_id'] }

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

  report['uniqueBrowsersCount'] = uniqueBrowsers.count
  report['totalSessions'] = totalSessions
  report['allBrowsers'] = uniqueBrowsers.sort.join(',')

  # Статистика по пользователям

  report['usersStats'] = {}

  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"

    sessions_times = user.sessions.map {|s| s['time'].to_i }
    sessions_browsers = user.sessions.map { |s| s['browser'].upcase }

    report['usersStats'][user_key] =     { 
      # Собираем количество сессий по пользователям
      'sessionsCount' => user.sessions.size,
      # Собираем количество времени по пользователям
      'totalTime' => "#{sessions_times.sum} min.",
      # Выбираем самую длинную сессию пользователя
      'longestSession' => "#{sessions_times.max} min.",
      # Браузеры пользователя через запятую
      'browsers' =>  sessions_browsers.sort.join(', '),
      # Хоть раз использовал IE?
      'usedIE' => sessions_browsers.any? { |b| b.include?('INTERNET EXPLORER') },
      # Всегда использовал только Chrome?
      'alwaysUsedChrome' => sessions_browsers.all? { |b| b.include?('CHROME') },
      # Даты сессий через запятую в обратном порядке в формате iso8601
      'dates' => user.sessions.map{ |s| s['date']}.sort.reverse 
    }
  end

  File.write(result_file_path, "#{report.to_json}\n")
end