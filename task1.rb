# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'set'

class User
  attr_accessor :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_user(user)
  fields = user
  parsed_result = {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

def parse_session(session)
  fields = session
  parsed_result = {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3].upcase,
    'time' => fields[4].to_i,
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

def work(file_path)
  file_lines = File.read(file_path).split("\n")

  users = []
  sessions = []
  uniqueBrowsers = Set.new([])
  sessions_count = 0

  file_lines.each do |line|
    cols = line.split(',')
    user = parse_user(cols) if cols[0] == 'user'
    session = parse_session(cols) if cols[0] == 'session'
    if user
      user_index = users.bsearch_index { |u| u.attributes['id'] == user['id']}
      if user_index
        users[user_index].attributes.merge!(user)
      else
        users << User.new(attributes: user, sessions: [])
      end
    else
      user_index = users.bsearch_index { |u| u.attributes['id'] == session['user_id']}
      unless user_index
        attributes = { 'id': session['user_id'] }
        users << User.new(attributes: attributes, sessions: [])
        user_index = -1
      end
      users[user_index].sessions << session
      uniqueBrowsers.add(session['browser'])
      sessions_count += 1
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

  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = sessions_count

  report['allBrowsers'] =
    uniqueBrowsers
      .sort
      .join(',')

  report['usersStats'] = {}

  collect_stats_from_users(report, users) do |user|
    user_browsers = user.sessions.map {|s| s['browser']}
    { 'sessionsCount' => user.sessions.count,
      'totalTime' => "#{user.sessions.map {|s| s['time']}.sum } min.", 
      'longestSession' => "#{ user.sessions.map {|s| s['time']}.max } min.",
      'browsers' => user_browsers.sort.join(', '),
      'usedIE' => user_browsers.any? { |b| b.start_with?('INTERNET EXPLORER') },
      'alwaysUsedChrome' => user_browsers.all? { |b| b.start_with?('CHROME') },  
      'dates' => user.sessions.map{ |s| s['date'] }.sort.reverse  
    }
  end

  File.write('result.json', "#{report.to_json}\n")
end
