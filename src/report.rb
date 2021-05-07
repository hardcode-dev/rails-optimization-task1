# frozen_string_literal: true

require 'json'
require 'pry'
require 'date'
require 'ruby-progressbar'
require_relative 'user'

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
    user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
  end
end

def work(file_name, lines_count = nil, progressbar_enabled = false)
  file_lines = File.read(file_name).split("\n")

  users = []
  sessions = []

  progressbar = ProgressBar.create(total: file_lines.count, format: '%a, %J, %E %B') if progressbar_enabled

  file_lines.each_with_index do |line, i|
    break if lines_count && i == lines_count

    progressbar.increment if progressbar_enabled

    cols = line.split(',')
    users += [parse_user(line)] if cols[0] == 'user'
    sessions += [parse_session(line)] if cols[0] == 'session'
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
  uniqueBrowsers = sessions.map { |session| session['browser'] }.uniq
  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] =
    sessions
      .map { |s| s['browser'] }
      .map { |b| b.upcase }
      .sort
      .uniq
      .join(',')

  # Статистика по пользователям
  users_objects = []
  sessions_by_user = sessions.group_by { |session| session['user_id'] }

  users.each do |user|
    attributes = user
    user_sessions = sessions_by_user[user['id']] || []
    user_object = User.new(attributes: attributes, sessions: user_sessions)
    users_objects += [user_object]
  end

  report['usersStats'] = {}

  collect_stats_from_users(report, users_objects) do |user|
    times = user.sessions.map { |s| s['time'].to_i }
    browsers = user.sessions.map { |s| s['browser'].upcase }
    {
      # Собираем количество сессий по пользователям
      'sessionsCount' => user.sessions.count,
      # Собираем количество времени по пользователям
      'totalTime' => times.sum.to_s + ' min.',
      # Выбираем самую длинную сессию пользователя
      'longestSession' => times.max.to_s + ' min.',
      # Браузеры пользователя через запятую
      'browsers' => browsers.sort.join(', '),
      # Хоть раз использовал IE?
      'usedIE' => browsers.any? { |b| b.upcase =~ /INTERNET EXPLORER/ },
      # Всегда использовал только Chrome?
      'alwaysUsedChrome' => browsers.all? { |b| b.upcase =~ /CHROME/ },
      # Даты сессий через запятую в обратном порядке в формате iso8601
      'dates' => user.sessions.map{|s| s['date']}.map {|d| Date.parse(d)}.sort.reverse.map { |d| d.iso8601 }
    }
  end

  File.write('result.json', "#{report.to_json}\n")
end
