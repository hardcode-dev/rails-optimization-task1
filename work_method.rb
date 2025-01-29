require 'json'
require 'pry'

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
    user_key = user.attributes['first_name'] + ' ' + user.attributes['last_name']
    report['usersStats'][user_key] = block.call(user)
  end
end

def work(file_name)
  file_lines = File.read(file_name).split("\n")

  users = []
  sessions = []

  file_lines.each do |line|
    cols = line.split(',')
    users.push(parse_user(cols)) if cols[0] == 'user'
    sessions.push(parse_session(cols)) if cols[0] == 'session'
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

  all_browsers = sessions.map { |s| s['browser'] }.uniq.sort

  report['uniqueBrowsersCount'] = all_browsers.count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] = all_browsers.join(',')

  # Статистика по пользователям
  users_objects = []
  groupped_sessions = sessions.group_by { |session| session['user_id'] }
                              .sort { |l, r| l[0].to_i <=> r[0].to_i }

  users.each do |user|
    user_sessions = groupped_sessions.bsearch { |sessions_group| user['id'].to_i - sessions_group[0].to_i }[1]
    user_object = User.new(attributes: user, sessions: user_sessions)
    users_objects.push(user_object)
  end

  report['usersStats'] = {}

  # Собираем количество времени по пользователям и самую длинную сессию пользователя
  collect_stats_from_users(report, users_objects) do |user|
    user_sessions = user.sessions
    time_map = user_sessions.map {|s| s['time'].to_i}
    user_browsers = user_sessions.map{ |s| s['browser'] }
    {
      'sessionsCount' => user_sessions.count,
      'totalTime' => time_map.sum.to_s + ' min.',
      'longestSession' => time_map.max.to_s + ' min.',
      'browsers' => user_browsers.sort.join(', '),
      'usedIE' => user_browsers.any? { |b| b =~ /INTERNET EXPLORER/ },
      'alwaysUsedChrome' => user_browsers.all? { |b| b =~ /CHROME/ },
      'dates' => user_sessions.map{|s| s['date']}.sort.reverse
    }
  end

  File.write('result.json', "#{report.to_json}\n")
end
