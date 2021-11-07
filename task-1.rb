# Deoptimized version of homework task

require 'json'
require 'date'
require 'pry'
require 'ostruct'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

UserStruct = Struct.new(:id, :first_name, :last_name)
SessionStruct = Struct.new(:user_id, :session_id, :browser, :time, :date)

def parse_user(user)
  fields = user.split(',', 5)
  UserStruct.new(
    fields[1],
    fields[2],
    fields[3]
  )
end

def parse_session(session)
  fields = session.split(',', 6)
  SessionStruct.new(
    fields[1],
    fields[2],
    fields[3],
    fields[4],
    fields[5]
  )
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes.first_name}" + ' ' + "#{user.attributes.last_name}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
  end
end
def work(filepath: 'data/data_large.txt')
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
  uniqueBrowsers = sessions.uniq { |session| session.browser }

  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] =
    sessions
      .map { |s| s.browser }
      .map { |b| b.upcase }
      .sort
      .uniq
      .join(',')

  # Статистика по пользователям
  grouped_sessions = sessions.group_by { |session| session.user_id }

  users_objects = file_lines.map do |line|
    next unless line.start_with?('user')
    user = parse_user(line)
    user_sessions = grouped_sessions[user.id]
    User.new(attributes: user, sessions: user_sessions)
  end.compact

  report[:totalUsers] = users_objects.count

  report['usersStats'] = {}

  collect_stats_from_users(report, users_objects) do |user|
    times = user.sessions.map {|s| s.time.to_i}
    browsers = user.sessions.map {|s| s.browser}.map {|b| b.upcase}
    {
      'sessionsCount' => user.sessions.count,
      'totalTime' => times.sum.to_s + ' min.',
      'longestSession' => times.max.to_s + ' min.',
      'browsers' => browsers.sort.join(', '),
      'usedIE' => browsers.any? { |b| b =~ /INTERNET EXPLORER/ },
      'alwaysUsedChrome' => browsers.all? { |b| b =~ /CHROME/ },
      'dates' => user.sessions.map{|s| Date.strptime(s.date).iso8601}.sort.reverse
    }
  end

  File.write('result.json', "#{report.to_json}\n")
end
