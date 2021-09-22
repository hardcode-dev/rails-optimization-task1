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

def parse_user(user)
  fields = user.split(',', 5)
  parsed_result = {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

def parse_session(session)
  fields = session.split(',', 6)
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

def work(filepath:)
  file_lines = File.read(filepath).split("\n")

  users = []
  sessions = []

  sessions = file_lines.map do |line|
    next unless line.start_with?('session')
    parse_session(line)
  end.compact

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

  report[:totalUsers] = 0

  # Подсчёт количества уникальных браузеров
  uniqueBrowsers = sessions.uniq { |session| session['browser'] }

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
  grouped_sessions = sessions.group_by { |session| session['user_id'] }

  users_objects = file_lines.map do |line|
    next unless line.start_with?('user')
    user = parse_user(line)
    user_sessions = grouped_sessions[user['id']]
    User.new(attributes: user, sessions: user_sessions)
  end.compact

  report[:totalUsers] = users_objects.count

  report['usersStats'] = {}

  collect_stats_from_users(report, users_objects) do |user|
    times = user.sessions.map {|s| s['time'].to_i}
    browsers = user.sessions.map {|s| s['browser']}.map {|b| b.upcase}
    {
      'sessionsCount' => user.sessions.count,
      'totalTime' => times.sum.to_s + ' min.',
      'longestSession' => times.max.to_s + ' min.',
      'browsers' => browsers.sort.join(', '),
      'usedIE' => browsers.any? { |b| b =~ /INTERNET EXPLORER/ },
      'alwaysUsedChrome' => browsers.all? { |b| b =~ /CHROME/ },
      'dates' => user.sessions.map{|s| Date.strptime(s['date']).iso8601}.sort.reverse
    }
  end

  File.write('result.json', "#{report.to_json}\n")
end
