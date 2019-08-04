require 'json'
require 'pry'
require 'date'
require 'set'

require 'ruby-progressbar'
require 'ruby-prof'

require_relative 'user'

class Work
  def initialize(file: 'data.txt', disable_gc: true)
    @file = file
    @disable_gc = disable_gc

    @sessions      = []
    @users_objects = []
    @report        = {}
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

    @report[:totalUsers] = @users_objects.count

    uniqueBrowsers = Set.new
    @sessions.each do |session|
      browser = session[:browser]
      uniqueBrowsers << browser unless uniqueBrowsers.include?(browser)
    end

    @report[:uniqueBrowsersCount] = uniqueBrowsers.count
    @report[:totalSessions]       = @sessions.count
    @report[:allBrowsers]         = @sessions.map { |s| s[:browser].upcase }.sort.uniq.join(',')
    @report[:usersStats]          = {}

    @users_objects.each do |user|
      user_key    = user.full_name
      users_stats = @report[:usersStats][user_key] || {}

      browsers           = user.sessions.map {|s| s[:browser].upcase }
      browsers_string    = browsers.sort.join(', ')
      user_sessions_time = user.sessions.map {|s| s[:time].to_i }

      @report[:usersStats][user_key] = users_stats.merge({
        sessionsCount: user.sessions.count,
        totalTime: "#{user_sessions_time.sum} min.",
        longestSession: "#{user_sessions_time.max} min.",
        browsers: browsers_string,
        usedIE: browsers.any? { |b| b.include?('INTERNET EXPLORER') },
        alwaysUsedChrome: browsers.all? { |b| b.include?('CHROME') },
        dates: user.sessions.map {|s| s[:date] }.sort.reverse
      })
    end

    File.write('result.json', "#{@report.to_json}\n")
  end

  private

  def parse_lines
    File.read(@file).split("\n")
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
end
