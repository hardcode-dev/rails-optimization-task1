# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'ruby-prof'
require 'stackprof'

require 'ruby-progressbar'

class User
  attr_reader :id, :name, :age
  attr_accessor :sessions

  def initialize(id, name, age)
    @id = id
    @name = name
    @age = age
    @sessions = []
  end
end

class Session

  attr_reader :browser, :time, :date

  def initialize(browser, time, date)
    @browser = browser
    @time = time
    @date = date
  end
end

def parse_user(user)
  fields = user.split(',')

  User.new(
    fields[1],
    fields[2] + ' ' + fields[3],
    fields[4]
  )
end

def parse_session(session, users)
  fields = session.split(',')

  session = Session.new(
    fields[3].upcase!,
    fields[4].to_i,
    fields[5],
  )

  user_id = fields[1]
  users[user_id].sessions << session
  session
end

def collect_stats_from_users(report, users, &block)
  users.each do |_id, user|
    user_key = user.name
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
  end
end

def work(file)
  file_lines = File.read(file).split("\n")

  users = {}
  unique_browsers = Set.new()

  progressbar = ProgressBar.create(
    total: 300000,
    format: '%a %J, %E %B'
  )
  file_lines.each do |line|
    cols = line.split(',')

    if cols[0] == 'user'
      user = parse_user(line)
      users[user.id] = user
    else
      session = parse_session(line, users)
      unique_browsers << session.browser
    end
    progressbar.increment
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

  report['totalSessions'] = users.values.sum { |user| user.sessions.size }

  report['allBrowsers'] = unique_browsers.sort.join(',')

  report['usersStats'] = {}

  # Собираем количество сессий по пользователям
  collect_stats_from_users(report, users) do |user|
    { 'sessionsCount' => user.sessions.count }
  end

  # Собираем количество времени по пользователям
  collect_stats_from_users(report, users) do |user|
    { 'totalTime' => user.sessions.map {|s| s.time }.sum.to_s + ' min.' }
  end

  # Выбираем самую длинную сессию пользователя
  collect_stats_from_users(report, users) do |user|
    { 'longestSession' => user.sessions.map {|s| s.time}.max.to_s + ' min.' }
  end

  # Браузеры пользователя через запятую
  collect_stats_from_users(report, users) do |user|
    { 'browsers' => user.sessions.map {|s| s.browser}.sort.join(', ') }
  end

  # Хоть раз использовал IE?
  collect_stats_from_users(report, users) do |user|
    { 'usedIE' => user.sessions.map{|s| s.browser}.any? { |b| b =~ /INTERNET EXPLORER/ } }
  end

  # Всегда использовал только Chrome?
  collect_stats_from_users(report, users) do |user|
    { 'alwaysUsedChrome' => user.sessions.map{|s| s.browser}.all? { |b| b =~ /CHROME/ } }
  end

  # Даты сессий через запятую в обратном порядке в формате iso8601
  collect_stats_from_users(report, users) do |user|
    { 'dates' => user.sessions.map{|s| s.date}.map {|d| Date.parse(d)}.sort.reverse.map { |d| d.iso8601 } }
  end

  File.write('result.json', "#{report.to_json}\n")
end

