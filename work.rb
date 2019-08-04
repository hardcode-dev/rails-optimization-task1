require 'json'
require 'pry'
require 'date'
require 'set'

require 'ruby-progressbar'
require 'ruby-prof'

require_relative 'user'

class Work
  def initialize(file: 'data.txt', disable_gc: true, start: 0, finish: 20_000)
    @file = file
    @disable_gc = disable_gc
    @start = start
    @finish = finish

    @sessions      = []
    @users_objects = []
  end

  def perform
    GC.disable if @disable_gc

    parse_lines.each do |line|
      fields = line.split(',')
      object = fields[0]

      if object == 'user'
        @users_objects << create_user(fields)
      elsif object == 'session'
        session = create_session(fields)
        @user.sessions << session if session[:user_id] == @user.id
        @sessions << session
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
    report[:totalUsers] = @users_objects.count

    # Подсчёт количества уникальных браузеров
    uniqueBrowsers = Set.new
    @sessions.each do |session|
      browser = session[:browser]
      uniqueBrowsers << browser unless uniqueBrowsers.include?(browser)
    end

    report[:uniqueBrowsersCount] = uniqueBrowsers.count
    report[:totalSessions] = @sessions.count
    report[:allBrowsers] = @sessions.map { |s| s[:browser].upcase }.sort.uniq.join(',')

    # Статистика по пользователям
    report[:usersStats] = {}

    # Собираем количество сессий по пользователям
    collect_stats_from_users(report, @users_objects) do |user|
      { sessionsCount: user.sessions.count }
    end

    # Собираем количество времени по пользователям
    collect_stats_from_users(report, @users_objects) do |user|
      { totalTime: user.sessions.map {|s| s[:time]}.map {|t| t.to_i}.sum.to_s + ' min.' }
    end

    # Выбираем самую длинную сессию пользователя
    collect_stats_from_users(report, @users_objects) do |user|
      { longestSession: user.sessions.map {|s| s[:time]}.map {|t| t.to_i}.max.to_s + ' min.' }
    end

    # Браузеры пользователя через запятую
    collect_stats_from_users(report, @users_objects) do |user|
      { browsers: user.sessions.map {|s| s[:browser]}.map {|b| b.upcase}.sort.join(', ') }
    end

    # Хоть раз использовал IE?
    collect_stats_from_users(report, @users_objects) do |user|
      { usedIE: user.sessions.map{|s| s[:browser]}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ } }
    end

    # Всегда использовал только Chrome?
    collect_stats_from_users(report, @users_objects) do |user|
      { alwaysUsedChrome: user.sessions.map{|s| s[:browser]}.all? { |b| b.upcase =~ /CHROME/ } }
    end

    # Даты сессий через запятую в обратном порядке в формате iso8601
    collect_stats_from_users(report, @users_objects) do |user|
      { dates: user.sessions.map{|s| s[:date]}.map {|d| Date.parse(d)}.sort.reverse.map { |d| d.iso8601 } }
    end

    File.write('result.json', "#{report.to_json}\n")
  end

  private

  def parse_lines
    File.read(@file).split("\n")[@start..@finish]
  end

  def create_user(fields)
    @user = User.new(attributes: {
      id: fields[1],
      first_name: fields[2],
      last_name: fields[3],
      age: fields[4],
      sessions: []
    })
  end

  def create_session(fields)
    {
      user_id: fields[1],
      session_id: fields[2],
      browser: fields[3],
      time: fields[4],
      date: fields[5]
    }
  end

  def collect_stats_from_users(report, users_objects)
    users_objects.each do |user|
      user_key    = user.full_name
      users_stats = report[:usersStats][user_key] || {}

      report[:usersStats][user_key] = users_stats.merge(yield(user))
    end
  end
end
