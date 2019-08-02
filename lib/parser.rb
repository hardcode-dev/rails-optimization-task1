require 'set'
require 'json'
require 'pry'
require 'date'
require_relative 'user'

class Parser
  attr_reader :file_path

  def initialize(file_path:)
    @file_path = file_path
  end

  def parse_user(user)
    {
      'id' => user[1],
      'first_name' => user[2],
      'last_name' => user[3],
      'age' => user[4]
    }
  end

  def parse_session(session)
    {
      'user_id' => session[1],
      'session_id' => session[2],
      'browser' => session[3],
      'time' => session[4],
      'date' => session[5]
    }
  end

  def collect_stats_from_users(report, users)
    users.each do |user|
      user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"
      report['usersStats'][user_key] ||= {}

      # Собираем количество сессий по пользователям
      report['usersStats'][user_key]['sessionsCount'] = user.sessions.count

      # Собираем количество времени по пользователям
      total_time = user.sessions.map {|s| s['time']}
      total_time.map! {|t| t.to_i}
      report['usersStats'][user_key]['totalTime'] = total_time.sum.to_s + ' min.'

      # Выбираем самую длинную сессию пользователя
      longest_session = user.sessions.map {|s| s['time']}
      longest_session.map! {|t| t.to_i}
      report['usersStats'][user_key]['longestSession'] = longest_session.max.to_s + ' min.'

      # Браузеры пользователя через запятую
      browsers = user.sessions.map {|s| s['browser']}
      browsers.map! {|b| b.upcase}.sort!
      report['usersStats'][user_key]['browsers'] = browsers.join(', ')

      # Хоть раз использовал IE?
      report['usersStats'][user_key]['usedIE'] = user.sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ }

      # Всегда использовал только Chrome?
      report['usersStats'][user_key]['alwaysUsedChrome'] = user.sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ }

      # Даты сессий через запятую в обратном порядке в формате iso8601
      dates = user.sessions.map {|s| s['date']}
      dates.map! {|d| Date.parse(d)}.sort!.reverse!.map! { |d| d.iso8601 }
      report['usersStats'][user_key]['dates'] = dates
    end
    report
  end

  def work
    file_lines = File.read(file_path).lines

    sessions = {}
    all_sessions = []
    users = []
    uniqueBrowsers = Set.new

    file_lines.each do |line|
      cols = line.split(',')

      if cols[0] == 'user'
        users << User.new(attributes: parse_user(cols))
      elsif cols[0] == 'session'
        session = parse_session(cols)
        sessions[session['user_id']] ||= []
        sessions[session['user_id']] << session
        all_sessions << session
        uniqueBrowsers << session['browser']
      end
    end

    users.each do |user|
      user.sessions = sessions[user.attributes['id']] || []
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

    report['uniqueBrowsersCount'] = uniqueBrowsers.count

    report['totalSessions'] = all_sessions.count

    all_browsers = all_sessions.map { |s| s['browser'] }
    all_browsers.map! { |b| b.upcase }.sort!.uniq!
    report['allBrowsers'] = all_browsers.join(',')

    # Статистика по пользователям

    report['usersStats'] = {}
    report = collect_stats_from_users(report, users)


    File.write('result.json', "#{report.to_json}\n")
  end
end

# Parser.new(file_path: '../data_large.txt').work
