# Deoptimized version of homework task

require 'json'
require 'pry'

# class User
#   attr_reader :attributes, :sessions

#   def initialize(attributes:, sessions:)
#     @attributes = attributes
#     @sessions = sessions
#   end
# end

def parse_user(fields)
  parsed_result = {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

def parse_session(fields)
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
    user_key = "#{user[:attributes]['first_name']} #{user[:attributes]['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key].merge!(block.call(user))
  end
end

def work(filename = 'data.txt', disable_gc: false)
  GC.disable if disable_gc
  file_lines = File.read(filename).split("\n")

  users = []
  sessions = []

  file_lines.each do |line|
    cols = line.split(',')
    users << parse_user(cols) if cols[0] == 'user'
    sessions << parse_session(cols) if cols[0] == 'session'
  end

  report = {}

  report['totalUsers'] = users.count

  # Подсчёт количества уникальных браузеров
  uniqueBrowsers = sessions.map{|s| s['browser']}.uniq.sort
  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] = uniqueBrowsers.join(',')

  # Статистика по пользователям
  users_objects = []

  grouped_sessions = sessions.group_by{|s| s['user_id']}

  users.each do |user|
    attributes = user
    user_sessions = grouped_sessions[user['id']]
    user_object = {attributes: attributes, sessions: user_sessions}
    users_objects << user_object
  end

  report['usersStats'] = {}

  collect_stats_from_users(report, users_objects) do |user|
    # Собираем количество сессий по пользователям
    { 'sessionsCount' => sessions_count(user),
    # Собираем количество времени по пользователям
    # { 'totalTime' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.' }
    'totalTime' => total_time(user),
    # # Выбираем самую длинную сессию пользователя
    # { 'longestSession' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.' }
    'longestSession' => longest(user),
    # Браузеры пользователя через запятую
    # { 'browsers' => user.sessions.map {|s| s['browser']}.map {|b| b.upcase}.sort.join(', ') }
    'browsers' => browsers(user),
    # Хоть раз использовал IE?
    # { 'usedIE' => user.sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ } }
    'usedIE' => ie(user),
    # Всегда использовал только Chrome?
    # { 'alwaysUsedChrome' => user.sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ } }
    'alwaysUsedChrome' => chrome(user),
    # Даты сессий через запятую в обратном порядке в формате iso8601
    # { 'dates' => user.sessions.map{|s| s['date']}.map {|d| Date.parse(d)}.sort.reverse.map { |d| d.iso8601 } }
    'dates' => dates(user)}
  end

  # File.write('result.json', "#{report.to_json}\n")
  File.write('result.json', "#{report.to_json}\n")
end


  def sessions_count(user)
    user[:sessions].count
  end

  def total_time(user)
    "#{user[:sessions].map{|s| s['time']}.sum} min."
  end

  def longest(user)
    "#{user[:sessions].map{|s| s['time']}.max} min."
    # "#{user[:sessions].reduce(0){|max, s| max = s['time'] if max < s['time']; max}} min."
  end

  def browsers(user)
    user[:sessions].map{|s| s['browser']}.sort.join(', ')
    # user[:sessions].map{|s| s['browser']}.sort_by{|s| s}.join(', ')
  end

  def ie(user)
    user[:sessions].any?{|s| s['browser'] =~ /internet explorer/i}
  end

  def chrome(user)
    user[:sessions].all?{|s| s['browser'] =~ /chrome/i}
  end

  def dates(user)
    user[:sessions].map{|s| s['date']}.sort.reverse
  end
