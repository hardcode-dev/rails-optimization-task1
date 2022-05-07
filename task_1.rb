# frozen_string_literal: true

# Optimized version of homework task

require 'json'
require 'pry'

# Parse file and collect all information
class Parser
  def initialize(file_name )
    @file_name = file_name
    @users_lines = []
    @users = []
    @sessions_counter = 0
    @browsers = []
    @report = {}
    @user_sessions = Hash.new { |h, k| h[k] = [] }
    work(@file_name)
  end

  def work(file_name)
    parse_file(file_name)
    add_sessions_to_user
    prefill_report
    process_user_sessions_stats
    save_report
  end

  def prefill_report
    uniq_browsers = @browsers.uniq
    @report['totalUsers'] = @users.length
    @report['uniqueBrowsersCount'] = uniq_browsers.length
    @report['totalSessions'] = @sessions_counter
    @report['allBrowsers'] = uniq_browsers.sort.join(',')
    @report['usersStats'] = {}
  end

  def parse_file(file_name)
    File.foreach(file_name) do |line|
      parse_line(line.chomp)
    end
  end

  def parse_line(line)
    attributes = line.split(',')
    attributes[0].start_with?('user') ? parse_user(attributes) : parse_session(attributes)
  end

  def parse_user(att)
    @users << {id: att[1], full_name: "#{att[2]} #{att[3]}"}
  end

  def parse_session(att)
    session = {user_id: att[1],
               browser: att[3].upcase,
               time: att[4].to_i,
               date: att[5]}

    @browsers << [session[:browser]]
    @sessions_counter += 1
    @user_sessions[session[:user_id]] << session
  end

  def add_sessions_to_user
    @users.each do |user|
      user[:sessions] = @user_sessions[user[:id]]
    end
  end

  def process_user_sessions_stats
    @users.each do |user|
      user_key = user[:full_name]
      @report['usersStats'][user_key] = parse_sessions_params(user)
    end
  end

  def parse_sessions_params(user)
    parsed_sessions = parse_user_sessions(user[:sessions])
    {
      sessionsCount: user[:sessions].length,
      totalTime: "#{parsed_sessions[0].sum} min.",
      longestSession: "#{parsed_sessions[0].max} min.",
      browsers: parsed_sessions[1].join(', '),
      usedIE: parsed_sessions[1].any? { |b| b.start_with?(/INTERNET EXPLORER/) },
      alwaysUsedChrome: parsed_sessions[1].all? { |b| b.start_with?(/CHROME/) },
      dates: parsed_sessions[2]
    }
  end

  def parse_user_sessions(user_sessions)
    times = []
    browsers = []
    dates = []

    user_sessions.each do |session|
      times << session[:time]
      browsers << session[:browser]
      dates << session[:date]
    end

    [times, browsers.sort, dates.sort.reverse]
  end

  def save_report
    File.write('result.json', "#{@report.to_json}\n")
  end
end

Parser.new(ARGV[0]) if __FILE__ == $0

