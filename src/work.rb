# frozen_string_literal: true

FILE_NAME = 'data.txt'

require 'json'
require 'pry'
require 'date'

require 'awesome_print'
# require 'progress_bar'

require_relative 'user.rb'

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
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5],
  }
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = user.key
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key].merge!(block.call(user))
  end
end

def work(limit: 5000, file_name: FILE_NAME)
  ap "start"
  users = {}
  sessions = []
  unique_browsers = []
  pb = ProgressBar.new([`wc -l #{file_name}`.to_i, limit].min) if defined? ProgressBar
  File.open(file_name).each.with_index do |line, ix|
    break if ix >= limit
    cols = line.split(',')
    if cols[0] == 'user'
      user_attrs = parse_user(line)
      users[user_attrs['id']] = user_attrs
    else
      session = parse_session(line)
      sessions.push session

      # Подсчёт количества уникальных браузеров
      browser = session['browser']
      unique_browsers.push browser unless unique_browsers.include?(browser)
    end
    pb&.increment!
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

  report['uniqueBrowsersCount'] = unique_browsers.count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] =
    sessions
      .map { |s| s['browser'] }
      .map { |b| b.upcase }
      .sort
      .uniq
      .join(',')

  # Статистика по пользователям
  users_objects_hash = {}

  sessions.each do |session|
    user_id = session['user_id']
    attributes = users[user_id]
    users_objects_hash[user_id] ||= User.new(attributes)
    users_objects_hash[user_id].add_session session
  end
  users_objects = users_objects_hash.values

  report['usersStats'] = {}

  collect_stats_from_users(report, users_objects) do |user|
    {
      # Собираем количество сессий по пользователям
      'sessionsCount' => user.sessions.count,
      # Собираем количество времени по пользователям
      'totalTime' => "#{user.total_session_time} min.",
      # Выбираем самую длинную сессию пользователя
      'longestSession' => "#{user.max_session_time} min.",
      # Браузеры пользователя через запятую
      'browsers' => user.sessions.map {|s| s['browser']}.map {|b| b.upcase}.sort.join(', '),
      # Хоть раз использовал IE?
      'usedIE' => user.sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ },
      # Всегда использовал только Chrome?
      'alwaysUsedChrome' => user.sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ },
      # Даты сессий через запятую в обратном порядке в формате iso8601
      'dates' => user.sessions.map{|s| s['date']}.map {|d| Date.parse(d)}.sort.reverse.map { |d| d.iso8601 }
    }
  end

  File.write('result.json', "#{report.to_json}\n")
  ap "finish"
end
