# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'benchmark/ips'

require_relative 'user'
require_relative 'test_me'

class Report

  def call(file_name = 'data_8000.txt')
    work(file_name)
  end

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

  def collect_stats_from_users(report, users_objects, &block)
    users_objects.each do |user|
      user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
      report['usersStats'][user_key] ||= {}
      report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
    end
  end

  def uniq_browsers_fast(browsers_dict)
    result = browsers_dict.keys
    result.sort!
  end

  def uniq_browsers_slow(sessions)
    result = []
    sessions.each do |session|
      browser = session['browser']
      result += [browser] if result.all? { |b| b != browser }
    end
    result
  end

  def work(file_name)
    file_lines = File.read(file_name).split("\n")

    users = []
    sessions = []
    sessions_by_user = {}
    uniq_browsers_dict = {}


    file_lines.each do |line|
      # user,76,Jerome,Corene,46
      # session,76,0,Chrome 23,42,2017-05-03
      cols = line.split(',')

      if cols[0] == 'user'
        users = users + [parse_user(line)]
      end

      if cols[0] == 'session'
        session_obj = parse_session(line)
        sessions = sessions + [session_obj]

        user_id = session_obj['user_id']
        sessions_by_user[user_id] = [] unless sessions_by_user[user_id]
        sessions_by_user[user_id] << session_obj

        browser = session_obj['browser']
        uniq_browsers_dict[browser] = true
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

    report[:totalUsers] = users.count

    # Подсчёт количества уникальных браузеров
    # uniqueBrowsers = uniq_browsers_slow(sessions)
    uniqueBrowsers = uniq_browsers_fast(uniq_browsers_dict)

    report['uniqueBrowsersCount'] = uniqueBrowsers.count

    report['totalSessions'] = sessions.count

    report['allBrowsers'] =
        sessions
            .map { |s| s['browser'] }
            .map { |b| b.upcase }
            .sort
            .uniq
            .join(',')

    # Статистика по пользователям
    users_objects = []

    users.each do |user|
      attributes = user

      # user_sessions = sessions.select { |session| session['user_id'] == user['id'] }
      # user_sessions = sessions_by_user

      user_id = user['id']
      user_sessions = sessions_by_user[user_id]

      user_object = User.new(attributes: attributes, sessions: user_sessions)
      users_objects = users_objects + [user_object]
    end

    report['usersStats'] = {}

    # Собираем количество сессий по пользователям
    collect_stats_from_users(report, users_objects) do |user|
      { 'sessionsCount' => user.sessions.count }
    end

    # Собираем количество времени по пользователям
    collect_stats_from_users(report, users_objects) do |user|
      { 'totalTime' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.' }
    end

    # Выбираем самую длинную сессию пользователя
    collect_stats_from_users(report, users_objects) do |user|
      { 'longestSession' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.' }
    end

    # Браузеры пользователя через запятую
    collect_stats_from_users(report, users_objects) do |user|
      { 'browsers' => user.sessions.map {|s| s['browser']}.map {|b| b.upcase}.sort.join(', ') }
    end

    # Хоть раз использовал IE?
    collect_stats_from_users(report, users_objects) do |user|
      { 'usedIE' => user.sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ } }
    end

    # Всегда использовал только Chrome?
    collect_stats_from_users(report, users_objects) do |user|
      { 'alwaysUsedChrome' => user.sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ } }
    end

    # Даты сессий через запятую в обратном порядке в формате iso8601
    collect_stats_from_users(report, users_objects) do |user|
      { 'dates' => user.sessions.map{|s| s['date']}.map {|d| Date.parse(d)}.sort.reverse.map { |d| d.iso8601 } }
    end

    # puts "### Completed, write to file"
    File.write('result.json', "#{report.to_json}\n")
  end

end

#
#
# Report.new.call(nil)