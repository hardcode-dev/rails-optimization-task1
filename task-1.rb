# Deoptimized version of homework task
require 'json'
require 'date'
require 'ruby-progressbar'

#require 'awesome_print'
#require 'ruby-prof'

#Deprecated
#class User
#  attr_reader :attributes, :sessions
#
#  def initialize(attributes:, sessions:)
#    @attributes = attributes
#    @sessions = sessions
#  end
#end

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

#Deprecated
def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
  end
end

def work filename = 'data.txt'
  puts "start work..."
  file_lines = File.read(filename).split("\n")

  progressbar = ProgressBar.create(
    total: file_lines.size,
    format: '%a, %J, %E, %B'
  ) if ProgressBarEnabler.show?

  users = []
  sessions = {}

  file_lines.each do |line|
    cols = line.split(',')
    users = users + [parse_user(line)] if cols[0] == 'user'
    if cols[0] == 'session'
      ses = parse_session(line)
      ses['user_id']
      if sessions[ses['user_id']]
        sessions[ses['user_id']] << ses
      else
        sessions[ses['user_id']] = [ses]
      end
    end
      #sessions = sessions + [] 
    progressbar.increment if ProgressBarEnabler.show?
  end
  all_sessions = sessions.flat_map{|e|e[1]}
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

  
  progressbar = ProgressBar.create(
    total: all_sessions.size,
    format: '%a, %J, %E, %B'
  ) if ProgressBarEnabler.show?

  # Подсчёт количества уникальных браузеров
  uniqueBrowsers = []
  all_sessions.each do |session|
    browser = session['browser']
    #uniqueBrowsers += [browser] if uniqueBrowsers.all? { |b| b != browser }
    uniqueBrowsers += [browser] unless uniqueBrowsers.include?(browser)
    progressbar.increment if ProgressBarEnabler.show?
  end

  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = all_sessions.count

  report['allBrowsers'] =
    all_sessions
      .map { |s| s['browser'] }
      .map { |b| b.upcase }
      .sort
      .uniq
      .join(',')

  # Статистика по пользователям
  users_objects = []

  progressbar = ProgressBar.create(
    total: users.size,
    format: '%a, %J, %E, %B'
  ) if ProgressBarEnabler.show?

  report['usersStats'] = {}
  users.each do |user|
    user_sessions = sessions[user['id']]
    user_key = "#{user['first_name']}" + ' ' + "#{user['last_name']}"
    report['usersStats'][user_key] ||= {}
    date_a = browser_a = time_a = []
    user_sessions.map do |s| 
      time_a = time_a + [s['time'].to_i]
      browser_a = browser_a + [s['browser'].upcase]
      date_a = date_a + [Date.strptime(s['date'], '%Y-%m-%d')]
    end

    reports = {
        'sessionsCount' => user_sessions.count,
        'totalTime' =>  (time_a.sum.to_s + ' min.'),
        'longestSession' => (time_a.max.to_s + ' min.'),
        'browsers' => browser_a.sort.join(', '),
        'usedIE' => browser_a.any? { |b| b =~ /INTERNET EXPLORER/ },
        'alwaysUsedChrome' => browser_a.all? { |b| b =~ /CHROME/ },
        'dates' => date_a.sort.reverse.map { |d| d.iso8601 }
    }
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(reports)


    progressbar.increment if ProgressBarEnabler.show?
  end

  File.write('result.json', "#{report.to_json}\n")
end
class ProgressBarEnabler
  @@flag = true
  def self.enable!
    @@flag = true
  end
  def self.disable!
    @@flag = false
  end  
  def self.show?
    @@flag
  end
end
#ProgressBarEnabler.disable!
#work('data/data1000.txt')
