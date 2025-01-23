# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require_relative 'utils/progress_bar_factory'
require_relative 'user'



def parse_user(user)
  _, id, first_name, last_name, age = user.split(',')
  full_name = "#{first_name}" + ' ' + "#{last_name}"
  {
    id:,
    first_name:,
    last_name:,
    full_name:,
    age:,
  }
end

def parse_session_by_user_id(session)
  _, user_id, session_id, browser, time, date = session.split(',')
  [
    user_id,
    browser,
    {
      user_id:,
      session_id:,
      browser:,
      time:,
      date:,
    }
  ]
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = user.full_name
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
  end
end

def work(path = 'fixtures/data.txt', gb_disable = false)
  GC.disable if gb_disable
  file_lines = File.read(path).split("\n")
  file_lines_count = file_lines.count

  users_storage = {}
  unique_browsers = Set[]
  total_session = 0

  
  user_attributes = {}
  i = 0
  while i < file_lines_count
    line = file_lines[i]
    cols = line.split(',')
    if cols[0] == 'user'
      user_attributes = parse_user(line)
      
      user = User.new(**user_attributes, sessions:[]) || users_storage[user_attributes[:id]]
      users_storage[user_attributes[:id]] = user
    end
    if cols[0] == 'session'
      user_id, browser, session_data = parse_session_by_user_id(line)
      # Подсчёт количества уникальных браузеров
      unique_browsers.add(browser.upcase)
      user = users_storage[user_id]
      if user
        time = session_data[:time].to_i
        user.add_sessions(session_data)
        user.inc
        user.update_total_time(time)
        user.use_ie = !(session_data[:browser] =~ /Internet Explorer/).nil? unless user.use_ie
        user.update_longest_session(time)
      end
      total_session += 1
    end
    i += 1
  end

  users_objects = users_storage.values
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

  report['totalUsers'] = users_storage.keys.count

  report['uniqueBrowsersCount'] = unique_browsers.size

  report['totalSessions'] = total_session

  report['allBrowsers'] = unique_browsers.sort.join(',')

  report['usersStats'] = {}


  # Собираем количество сессий по пользователям
  collect_stats_from_users(report, users_objects) do |user|
    { 'sessionsCount' => user.sessions_count }
  end

  # Собираем количество времени по пользователям
  collect_stats_from_users(report, users_objects) do |user|
    { 'totalTime' => user.total_time.to_s + ' min.' }
  end

  # Выбираем самую длинную сессию пользователя
  collect_stats_from_users(report, users_objects) do |user|
    { 'longestSession' => user.longest_session.to_s + ' min.' }
  end

  # Браузеры пользователя через запятую
  collect_stats_from_users(report, users_objects) do |user|
    { 'browsers' => user.sessions.map {|s| s[:browser]}.map {|b| b.upcase}.sort.join(', ') }
  end

  # Хоть раз использовал IE?
  collect_stats_from_users(report, users_objects) do |user|
    { 'usedIE' => user.use_ie }
  end

  # Всегда использовал только Chrome?
  collect_stats_from_users(report, users_objects) do |user|
    { 'alwaysUsedChrome' => user.sessions.map{|s| s[:browser]}.all? { |b| b.upcase =~ /CHROME/ } }
  end

  # Даты сессий через запятую в обратном порядке в формате iso8601
  collect_stats_from_users(report, users_objects) do |user|
    { 'dates' => user.sessions.map{|s| s[:date]}.map {|d| Date.parse(d)}.sort.reverse.map { |d| d.iso8601 } }
  end

  File.write('result.json', "#{report.to_json}\n")
end