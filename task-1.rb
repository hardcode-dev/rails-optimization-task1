# frozen_string_literal: true
# Deoptimized version of homework task

require 'oj'
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
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

def parse_session(fields)
  {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3].upcase,
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

def work
  file_lines = File.read('data.txt').split("\n")

  users = []
  sessions = []

  file_lines.each do |line|
    cols = line.split(',')
    users << parse_user(cols) if cols[0] == 'user'
    sessions << parse_session(cols) if cols[0] == 'session'
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
  uniqueBrowsers = sessions.map { |s| s['browser'] }.uniq

  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] = uniqueBrowsers.sort.join(',')

  # Статистика по пользователям
  users_objects = []

  user_sessions = sessions.group_by { |session| session['user_id'] }
  users.each do |user|
    users_objects << User.new(attributes: user, sessions: user_sessions[user['id']])
  end

  report['usersStats'] = {}

  # Собираем количество сессий по пользователям
  collect_stats_from_users(report, users_objects) do |user|
    times = []
    browsers = []
    dates = []
    user.sessions.each do |s|
      times << s['time'].to_i
      browsers << s['browser']
      dates << s['date']
    end
    {
      'sessionsCount' => user.sessions.count,
      'totalTime' => times.sum.to_s + ' min.',
      'longestSession' => times.max.to_s + ' min.',
      'browsers' => browsers.sort.join(', '),
      'usedIE' => browsers.any? { |b| b =~ /INTERNET EXPLORER/ },
      'alwaysUsedChrome' => browsers.all? { |b| b =~ /CHROME/ },
      'dates' => dates.sort.reverse
    }
  end

  File.write('result.json', "#{Oj.dump(report, mode: :compat)}\n")
end
