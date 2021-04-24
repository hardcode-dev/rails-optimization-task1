# Deoptimized version of homework task

require 'json'
require 'pry'
require 'oj'

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


class User
  attr_reader :attributes, :sessions, :times, :browsers, :dates, :used_ie, :always_used_chrome

  def initialize(attributes:)
    @attributes = attributes
    @sessions = []
    @dates = []
    @times = []
    @browsers = []
    @used_ie = false
    @always_used_chrome = true
  end

  def push_session(session)
    @sessions.push(session)
    @dates.push(session['date'])
    @browsers.push(session['browser'])
    @used_ie ||= (session['browser'] =~ /INTERNET EXPLORER/ && true)
    @always_used_chrome &&= (session['browser'] =~ /CHROME/ || false)
    @times.push(session['time'].to_i)
  end
end

def parse_user(user)
  fields = user.split(',')
  parsed_result = {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

def parse_session(session)
  fields = session.split(',')
  parsed_result = {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3].upcase,
    'time' => fields[4],
    'date' => fields[5],
  }
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
  end
end

def work(file_name)
  file_lines = File.read(file_name).split("\n")

  users_objects = {}

  sessions = []

  file_lines.each do |line|
    if line.start_with?('user')
      user_attrs = parse_user(line)
      users_objects[user_attrs['id']] = User.new(attributes: user_attrs)
    elsif line.start_with?('session')
      session_attrs = parse_session(line)
      users_objects[session_attrs['user_id']].push_session(session_attrs)
      sessions.push(session_attrs)
    end
  end

  report = {}

  report['totalUsers'] = users_objects.size

  # Подсчёт количества уникальных браузеров

  browsers_struct = sessions.group_by { |a| a['browser'] }

  report['uniqueBrowsersCount'] = browsers_struct.size
  report['totalSessions'] = sessions.count
  report['allBrowsers'] = browsers_struct.keys.sort.join(',')

  report['usersStats'] = {}

  collect_stats_from_users(report, users_objects.values) do |user|
    {
      'sessionsCount' => user.sessions.count, # Собираем количество сессий по пользователям
      'totalTime' => "#{user.times.sum} min.", # Собираем количество времени по пользователям
      'longestSession' => "#{user.times.max} min.", #Выбираем самую длинную сессию пользователя
      'browsers' => user.browsers.sort.join(', '), # Браузеры пользователя через запятую
      'usedIE' => user.used_ie || false, # Хоть раз использовал IE?
      'alwaysUsedChrome' => user.always_used_chrome || false, # Всегда использовал только Chrome?
      'dates' => user.dates.sort.reverse # Даты сессий через запятую в обратном порядке в формате iso8601
    }
  end

  File.write('result.json', "#{Oj.dump(report)}\n")
end
