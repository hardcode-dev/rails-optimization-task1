# Deoptimized version of homework task
require_relative 'user'

require 'json'
# require 'pry'
require 'date'
require 'benchmark'
# require 'byebug'

class Parser
  def initialize(data:, result:, disable_gc: true)
    @data = data
    @result = result
    GC.disable if disable_gc
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

  def collect_stats_from_users(report, users_objects)
    users_objects.each do |user|
      user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"
      # report['usersStats'][user_key] ||= {}

      report_by_user_key = report['usersStats'][user_key] ||= {}

      # Собираем количество сессий по пользователям
      report_by_user_key['sessionsCount'] = user.sessions.count

      # Собираем количество времени по пользователям
      report_by_user_key['totalTime'] = user.sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.'

      # Выбираем самую длинную сессию пользователя
      report_by_user_key['longestSession'] = user.sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.'

      # Браузеры пользователя через запятую
      report_by_user_key['browsers'] = user.sessions.map {|s| s['browser']}.map {|b| b.upcase}.sort.join(', ')

      # Хоть раз использовал IE?
      report_by_user_key['usedIE'] = user.sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ }

      # Всегда использовал только Chrome?
      report_by_user_key['alwaysUsedChrome'] = user.sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ }

      # Даты сессий через запятую в обратном порядке в формате iso8601
      # report_by_user_key['dates'] = user.sessions.map{|s| s['date']}.map {|d| Date.parse(d)}.sort.reverse.map { |d| d.iso8601 }
      report_by_user_key['dates'] = user.sessions.map{|s| s['date']}.map {|d| Date.strptime(d, '%Y-%m-%d')}.sort.reverse
    end
  end

  def work
    file_lines = File.read(@data).split("\n")

    users = []
    sessions = []

    file_lines.each do |line|
      cols = line.split(',')
      users += [parse_user(line)] if cols[0] == 'user'
      sessions += [parse_session(line)] if cols[0] == 'session'
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
    unique_browsers = sessions.map do |session|
      session['browser']
    end.uniq

    report['uniqueBrowsersCount'] = unique_browsers.count

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
    sessions_by_user_id ||= sessions.group_by { |session| session['user_id'] }

    users.each do |user|
      user_sessions = sessions_by_user_id[user['id']] || []
      user_object = User.new(attributes: user, sessions: user_sessions)
      users_objects += [user_object]
    end

    report['usersStats'] = {}

    collect_stats_from_users(report, users_objects)

    File.write(@result, "#{report.to_json}\n")
  end
end

Parser.new(data: 'data/data3250.txt', result: 'data/result.json', disable_gc: true).work
