# Deoptimized version of homework task

require 'json'
require 'date'

class User
  attr_accessor :attributes, :sessions

  @@users ||= []

  def self.count
    @@users.size
  end

  def self.all
    @@users
  end

  def update
    yield self
  end

  def self.find(id)
    @@users.detect { |user| user.attributes[:id] == id }
  end

  def initialize(attributes:, sessions: { sessionsCount: 0,
                                          totalTime: 0,
                                          longestSession: 0,
                                          browsers: [],
                                          dates: [] } )
    @attributes = attributes
    @sessions = sessions
    @@users << self
  end

  def used_ie?
    sessions[:browsers].any? { |browser| browser =~ /Internet Explorer/ }
  end

  def always_used_chrome?
    sessions[:browsers].all? { |browser| browser =~ /Chrome/ }
  end
end

def parse_user(fields)
  {
    id: fields[1],
    first_name: fields[2],
    last_name: fields[3]
  }
end

# TODO Не нужная информация. Быстрей сразу агрегировать данные.
def parse_session(fields)
  {
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
    @report['usersStats'][user_key] ||= {}
    @report['usersStats'][user_key] = @report['usersStats'][user_key].merge(block.call(user))
  end
end

def work(file = 'data.txt', disable_gc: false)
  GC.disable if disable_gc

  @file_result = File.new('result.json', 'w')
  @report = { totalUsers: 0, uniqueBrowsersCount: 0, totalSessions: 0, allBrowsers: 0}
  @sessions = []
  @users_objects = []
  @uniqueBrowsers = []

  File.foreach(file) do |line|
    cols = line.split(',')

    if cols.first.eql? 'user'
      User.new(attributes: parse_user(cols))
    elsif cols.first.eql? 'session'
      User.find(cols[1]).update do |user|
        user.sessions[:sessionsCount] += 1
        user.sessions[:browsers] << cols[3]
        user.sessions[:dates] << cols[5].chomp
        user.sessions[:totalTime] += cols[4].to_i
        user.sessions[:longestSession] = cols[4].to_i if user.sessions[:longestSession] < cols[4].to_i
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



    # Подсчёт количества уникальных браузеров

    # @sessions.each do |session|
    #   browser = session['browser']
    #   @uniqueBrowsers << browser if @uniqueBrowsers.all? { |b| b != browser }
    # end

    @report[:allBrowsers] =
      @sessions
        .map { |s| s['browser'] }
        .map { |b| b.upcase }
        .sort
        .uniq
        .join(',')

    # Статистика по пользователям

    # @users.each do |user|
    #   attributes = user
    #   user_sessions = @sessions.select { |session| session['user_id'] == user['id'] }
    #   user_object = User.new(attributes: attributes, sessions: user_sessions)
    #   @users_objects << user_object
    # end

    @report['usersStats'] ||= {}

    # Собираем количество сессий по пользователям
    collect_stats_from_users(@report, @users_objects) do |user|
      { 'sessionsCount' => user.sessions.count }
    end

    # Собираем количество времени по пользователям
    collect_stats_from_users(@report, @users_objects) do |user|
      { 'totalTime' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.' }
    end

    # Выбираем самую длинную сессию пользователя
    collect_stats_from_users(@report, @users_objects) do |user|
      { 'longestSession' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.' }
    end

    # Браузеры пользователя через запятую
    collect_stats_from_users(@report, @users_objects) do |user|
      { 'browsers' => user.sessions.map {|s| s['browser']}.map {|b| b.upcase}.sort.join(', ') }
    end

    # Хоть раз использовал IE?
    collect_stats_from_users(@report, @users_objects) do |user|
      { 'usedIE' => user.sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ } }
    end

    # Всегда использовал только Chrome?
    collect_stats_from_users(@report, @users_objects) do |user|
      { 'alwaysUsedChrome' => user.sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ } }
    end

    # Даты сессий через запятую в обратном порядке в формате iso8601
    collect_stats_from_users(@report, @users_objects) do |user|
      { 'dates' => user.sessions.map{|s| s['date']}.map {|d| Date.parse(d)}.sort.reverse.map { |d| d.iso8601 } }
    end
  end


  @report[:totalUsers] = User.count
  @report[:uniqueBrowsersCount] += @uniqueBrowsers.count
  @report[:totalSessions] += @sessions.count
  @file_result.write("#{@report.to_json}\n")
  @file_result.close
end
