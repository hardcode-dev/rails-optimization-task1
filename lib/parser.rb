require 'set'
require 'oj'
require 'json'
require 'pry'
require 'date'
require 'ruby-progressbar'

class Parser
  attr_reader :file_path

  def initialize(file_path:)
    @file_path = file_path
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
  def work
    # Didn't use IO.foreach(file_path) here to have access to lines.size for Progressbar
    lines = File.readlines(file_path)

    users = []
    sessions = {}
    total_sessions_count = 0
    unique_browsers = Set.new
    # progressbar = ProgressBar.create(title: 'Parse lines', total: lines.size)

    lines.each do |line|
      cols = line.split(',')

      if cols[0] == 'user'
        users << parse_user(cols)
      elsif cols[0] == 'session'
        session = parse_session(cols)
        sessions[session[:user_id]] ||= []
        sessions[session[:user_id]] << session
        total_sessions_count += 1
        unique_browsers << session[:browser]
      end

      # progressbar.increment
    end

    report = {
      'totalUsers' => users.size,
      'uniqueBrowsersCount' => unique_browsers.size,
      'totalSessions' => total_sessions_count,
      'allBrowsers' => unique_browsers.to_a.sort!.join(',').upcase,
      'usersStats' => collect_stats_from_users(users, sessions)
    }

    json = Oj.dump(report) << "\n"

    File.write('result.json', json)
  end

  def parse_user(user)
    {
      id: user[1],
      first_name: user[2],
      last_name: user[3],
      age: user[4]
    }
  end

  def parse_session(session)
    {
      user_id: session[1],
      session_id: session[2],
      browser: session[3],
      time: session[4].to_i,
      date: session[5]
    }
  end

  def collect_stats_from_users(users, sessions)
    users_report = {}
    # progressbar = ProgressBar.create(title: 'Collect users info', total: users.size)

    users.each do |user|
      user_sessions = sessions[user[:id]] || []

      total_sessions_time = 0
      longest_session = 0
      browsers = []
      used_ie = false
      used_chrome_only = true
      dates = []

      user_sessions.each do |session|
        session_time = session[:time]
        session_browser = session[:browser]

        total_sessions_time += session_time
        browsers << session_browser
        longest_session = session_time if session_time > longest_session
        used_ie = true if !used_ie && session_browser.match?(/INTERNET EXPLORER/i)
        used_chrome_only = false if used_chrome_only && !session_browser.match?(/CHROME/i)
        dates << session[:date].chomp
      end

      user_report = {
        'sessionsCount' => user_sessions.size,
        'totalTime' => "#{total_sessions_time} min.",
        'longestSession' => "#{longest_session} min.",
        'browsers' => browsers.sort!.join(', ').upcase,
        'usedIE' => used_ie,
        'alwaysUsedChrome' => used_chrome_only,
        'dates' => dates.sort!.reverse!
      }

      user_key = "#{user[:first_name]} #{user[:last_name]}"
      users_report[user_key] = user_report

      # progressbar.increment
    end

    users_report
  end
end
