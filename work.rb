require 'json'
require 'pry'

require_relative 'user.rb';

def parse_user(fields)
  {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
    'sessions' => []
  }
end

def parse_session(fields)
  {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5],
  }
end

def work(filename:, disable_gc: false)
  GC.disable if disable_gc

  report = {
    'totalUsers' => nil,
    'uniqueBrowsersCount' => nil,
    'totalSessions' => nil,
    'allBrowsers' => nil,
    'usersStats' => {}
  }

  users = []
  sessions = []
  browsers = []

  file_lines = File.read(filename).split("\n")

  file_lines.each do |line|
    line_arr = line.split(',')
    type = line_arr[0]
    users << parse_user(line_arr) if type == 'user'
    if type == 'session'
      session = parse_session(line_arr)
      sessions << session
      users.last['sessions'] << session
      browsers << session['browser'].upcase
    end
  end
  browsers.uniq!

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

  report['totalUsers'] = users.count
  report['totalSessions'] = sessions.count

  # Подсчёт количества уникальных браузеров
  report['uniqueBrowsersCount'] = browsers.count
  report['allBrowsers'] = browsers.sort.join(',')

  # Статистика по пользователям
  users.each do |attrs|
    user = User.new(attributes: attrs)
    report['usersStats'][user.key] = user.to_json
  end

  File.write('result.json', "#{report.to_json}\n")
end
