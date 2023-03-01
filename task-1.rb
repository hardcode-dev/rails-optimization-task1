# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'
require 'progressbar'
require 'benchmark'
require 'set'

class User
  attr_accessor :attributes, :sessions
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

def work(input, output, rows_count: nil, gc_disable: false)
  GC.disable if gc_disable

  file_lines = if rows_count.nil?
    File.read(input).split("\n")
  else
    File.foreach(input).first(rows_count)
  end

  users = {}
  sessions = []

  file_lines.each do |line|
    fields = line.split(',')

    if fields[0] == 'user'
      user = parse_user(fields)

      users[user['id']] ||= User.new
      users[user['id']].attributes = user
    end

    if fields[0] == 'session'
      session = parse_session(fields)
      sessions << session

      users[session['user_id']] ||= User.new
      users[session['user_id']].sessions ||= [] 
      users[session['user_id']].sessions << session
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
  uniqueBrowsers = Set.new
  sessions.each do |session|
    uniqueBrowsers.add session['browser'].upcase
  end

  report['uniqueBrowsersCount'] = uniqueBrowsers.count
  report['totalSessions'] = sessions.count
  report['allBrowsers'] = uniqueBrowsers.sort.join(',')
  report['usersStats'] = {}

  collect_stats_from_users(report, users.values) do |user|
    times, browsers, dates = [], [], []

    used_ie = false
    always_used_chrome = true

    user.sessions.each do |s|
      times << s['time'].to_i
      dates << s['date']

      b = s['browser'].upcase
      browsers << b

      next if used_ie
      used_ie = true if b =~ /INTERNET EXPLORER/

      next unless always_used_chrome
      always_used_chrome = false unless b =~ /CHROME/
    end

    { 
      'sessionsCount' => user.sessions.count,
      'totalTime' => (times.sum.to_s + ' min.'),
      'longestSession' => (times.max.to_s + ' min.'),
      'browsers' => browsers.sort.join(', '),
      'usedIE' => used_ie,
      'alwaysUsedChrome' => always_used_chrome,
      'dates' => dates.sort.reverse
    }
  end

  File.write(output, "#{report.to_json}\n")
end

