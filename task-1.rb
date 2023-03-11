# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'ruby-progressbar'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def work(file: nil, disable_gc: false, progressbar_use: false)
  file ||= ENV['DATA_FILE'] || 'data.txt'

  puts "Start work for file: #{file}"

  GC.disable if disable_gc

  file_lines = File.read(file).split("\n")

  progressbar_create(file_lines.count) if progressbar_use

  @users = []
  @sessions = []

  file_lines.each do |line|
    cols = line.split(',')

    if cols[0] == 'user'
      attributes = parse_user(cols)
      @users << User.new(attributes: attributes, sessions: [])
    else
      session = parse_session(cols)
      @users.last.sessions << session
      @sessions << session
    end

    @progressbar.increment if progressbar_use
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

  collect_report_for_users

  File.write('result.json', "#{report.to_json}\n")
end

def progressbar_create(total_lines)
  @progressbar = ProgressBar.create(
    total: total_lines,
    format: '%a, %J, %E %B'
  )
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
  end
end

def parse_user(cols)
  {
    'id' => cols[1],
    'first_name' => cols[2],
    'last_name' => cols[3],
    'age' => cols[4],
  }
end

def parse_session(cols)
  {
    'user_id' => cols[1],
    'session_id' => cols[2],
    'browser' => cols[3],
    'time' => cols[4],
    'date' => cols[5],
  }
end

def collect_report_for_users
  @users.each do |user|
    report['usersStats'][user_key(user)] = collect_data_for_user(user)
  end
end

def user_key(user)
  "#{user.attributes['first_name']} #{user.attributes['last_name']}"
end

def collect_data_for_user(user)
  {
    sessionsCount: collect_sessions_count(user),
    totalTime: collect_total_time(user),
    longestSession: collect_longest_session(user),
    browsers: collect_browsers(user),
    usedIE: collect_used_ie(user),
    alwaysUsedChrome: collect_always_used_chrome(user),
    dates: collect_dates(user)
  }
end

def report
  @report ||= {
    totalUsers: @users.count,
    'uniqueBrowsersCount' => uniqueBrowsers.count,
    'totalSessions' => @sessions.count,
    'allBrowsers' => all_browsers,
    'usersStats' => {}
  }
end

def uniqueBrowsers
  @uniqueBrowsers ||= @sessions.map { |s| s['browser'] }.uniq
end

def all_browsers
  @sessions
      .map { |s| s['browser'] }
      .map { |b| b.upcase }
      .sort
      .uniq
      .join(',')
end

def collect_sessions_count(user)
  user.sessions.count
end

def collect_total_time(user)
  user.sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.'
end

def collect_longest_session(user)
  user.sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.'
end

def collect_browsers(user)
  user.sessions.map {|s| s['browser']}.map {|b| b.upcase}.sort.join(', ')
end

def collect_used_ie(user)
  user.sessions.map{|s| s['browser']}.any? { |b| b.upcase.start_with? 'INTERNET EXPLORER' }
end

def collect_always_used_chrome(user)
  user.sessions.map{|s| s['browser']}.all? { |b| b.start_with? 'CHROME' }
end

def collect_dates(user)
  user.sessions.map{|s| s['date']}.sort.reverse
end
