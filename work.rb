require 'json'
require 'date'
require 'minitest/autorun'
require 'stackprof'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_user(cols)
  _, id, first_name, last_name, age = cols.split(',')
  {
    'id' => id,
    'first_name' => first_name,
    'last_name' => last_name,
    'age' => age,
  }
end

def parse_session(cols)
  _, user_id, session_id, browser, time, date = cols.split(',')
  {
    'user_id' => user_id,
    'session_id' => session_id,
    'browser' => browser,
    'time' => time,
    'date' => date,
  }
end

def work(filename = 'data.txt')
  report = {}

  current_user = nil
  uniqueBrowsers = Set.new
  totalSessions = 0
  user_object = nil
  users_objects = []

  File.readlines(filename, chomp: true).each do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      current_user = parse_user(line)
      user_object = User.new(attributes: current_user, sessions: [])
      users_objects.push user_object
    elsif cols[0] == 'session'
      session = parse_session(line)
      user_object.sessions.push session

      totalSessions += 1
      uniqueBrowsers.add(session['browser'].upcase)
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

  report['totalUsers'] = users_objects.count

  # Подсчёт количества уникальных браузеров
  report['uniqueBrowsersCount'] = uniqueBrowsers.count
  report['totalSessions'] = totalSessions
  report['allBrowsers'] = uniqueBrowsers.sort.join(',')

  report['usersStats'] = {}

  cached_dates = {}

  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"

    times = user.sessions.map { |s| s['time'].to_i }
    browsers = user.sessions.map { |s| s['browser'].upcase }

    dates = user.sessions.map do |session|
      cached_dates[session['date']] ||= Date.parse(session['date'])
      cached_dates[session['date']]
    end

    report['usersStats'][user_key] = {
      'sessionsCount' => user.sessions.count,
      'totalTime' => "#{times.sum.to_s} min.",
      'longestSession' => "#{times.max.to_s} min.",
      'browsers' => browsers.sort.join(', '),
      'usedIE' => browsers.any? { |b| b =~ /INTERNET EXPLORER/ },
      'alwaysUsedChrome' =>  browsers.all? { |b| b =~ /CHROME/ },
      'dates' => dates.sort.reverse.map { |d| d.iso8601 }
    }
  end

  File.write('result.json', "#{report.to_json}\n")
end
