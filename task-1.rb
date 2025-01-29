# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'

def collect_user_data(attributes, sessions)
  user_key = "#{attributes[:first_name]}" + ' ' + "#{attributes[:last_name]}"
  times, browsers, dates = [], [], []
  sessions.each do |session|
    times << session[:time].to_i
    browsers << session[:browser]
    dates << session[:date]
  end

  result = {
    # Собираем количество сессий по пользователям
    'sessionsCount' => sessions.count,
    # Собираем количество времени по пользователям
    'totalTime' => times.sum.to_s + ' min.',
    # Выбираем самую длинную сессию пользователя
    'longestSession' => times.max.to_s + ' min.',
    # Браузеры пользователя через запятую
    'browsers' => browsers.sort.join(', '),
    # Хоть раз использовал IE?
    'usedIE' => browsers.any? { |b| b.include? 'INTERNET EXPLORER' },
    # Всегда использовал только Chrome?
    'alwaysUsedChrome' => browsers.all? { |b| b.include? 'CHROME' },
    # Даты сессий через запятую в обратном порядке в формате iso8601
    'dates' => dates.sort.reverse
  }

  [user_key, result]
end

def parse_user(fields)
  {
    id: fields[1],
    first_name: fields[2],
    last_name: fields[3]
  }
end

def parse_session(fields)
  {
    user_id: fields[1],
    browser: fields[3].upcase,
    time: fields[4],
    date: fields[5]
  }
end

def work(file_path)
  file_lines = File.read(file_path).split("\n")

  users = []
  sessions = []
  sessions_by_user = {}

  file_lines.each do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      users << parse_user(cols)
    elsif cols[0] == 'session'
      session = parse_session(cols)
      sessions << session
      sessions_by_user[session[:user_id]] ||= []
      sessions_by_user[session[:user_id]] << session
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
  uniqueBrowsers = sessions.map { |s| s[:browser] }.sort.uniq
  report['uniqueBrowsersCount'] = uniqueBrowsers.count
  report['totalSessions'] = sessions.count
  report['allBrowsers'] = uniqueBrowsers.join(',')

  # Статистика по пользователям
  report['usersStats'] = {}
  users.each do |attributes|
    key, data = collect_user_data(attributes, sessions_by_user[attributes[:id]])
    report['usersStats'][key] = data
  end

  File.write('result.json', "#{report.to_json}\n")
end
