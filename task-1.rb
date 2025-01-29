
# Deoptimized version of homework task
require 'json'
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
    'age' => fields[4]
  }
end

def parse_session(fields)
  {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4].to_i,
    'date' => fields[5]
  }
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

def collect_stats_from_users(report, users_objects)

  users_objects.each do |user|

    user_key = "#{user.attributes['first_name']} " << "#{user.attributes['last_name']}"

    report['usersStats'][user_key] ||= {
      'sessionsCount' => user.sessions.size,
      'totalTime' => user.sessions.map { |s| s['time'] }.sum.to_s << ' min.',
      'longestSession' => user.sessions.map { |s| s['time'] }.max.to_s << ' min.',
      'browsers' => user.sessions.map { |s| s['browser'] }.sort.join(', '),
      'usedIE' => user.sessions.map{ |s| s['browser'] }.any? { |b| b =~ /INTERNET EXPLORER/ },
      'alwaysUsedChrome' => user.sessions.map{ |s| s['browser'] }.all? { |b| b =~ /CHROME/ },
      'dates' => user.sessions.map{ |s| s['date'] }.sort.reverse
    }
  end
end

def work(file, disable_gc)
  # puts 'start ...'
  # GC.disable if disable_gc

  file_lines = File.read(file).split("\n")

  users = []
  sessions = []

  unique_browsers = {}

  file_lines.each do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      users << parse_user(cols)
    else
      unique_browsers[cols[3].upcase!] = nil
      sessions << parse_session(cols)
    end
  end

  report = {}

  report[:totalUsers] = users.count

  # Подсчёт количества уникальных браузеров
  report['uniqueBrowsersCount'] = unique_browsers.size

  report['totalSessions'] = sessions.count

  report['allBrowsers'] =
    sessions
    .map { |s| s['browser'] }
    .sort
    .uniq
    .join(',')

  users_objects = []

  sessions_by_user = sessions.group_by { |session| session['user_id'] }

  users.each do |user|
    users_objects << User.new(attributes: user, sessions: sessions_by_user[user['id']] || [])
  end

  report['usersStats'] = {}

  collect_stats_from_users(report, users_objects)

  File.write('result.json', "#{report.to_json}\n")

  # puts 'end ...'
end
