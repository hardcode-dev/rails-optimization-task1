# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'set'

class Refactored

  def initialize
    @total_sessions_count = 0
    @unique_browsers = Set.new
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

  def parse_session(result, session)
    @total_sessions_count += 1
    fields = session.split(',')
    user_id = fields[1]
    browser = fields[3]
    @unique_browsers.add(browser)

    session = {
         'session_id' => fields[2],
         'browser' => browser,
         'time' => fields[4],
         'date' => fields[5],
    }
    result[user_id] = if result[user_id].nil?
                        [session]
                      else
                        result[user_id] + [session]
                      end
    result
  end

  def collect_stats_from_users(report, users_objects, &block)
    users_objects.each do |user|
      user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
      report['usersStats'][user_key] ||= {}

    end
  end

  def work(file_name)
    file_lines = File.read(file_name).split("\n")

    users = []
    sessions = {}

    file_lines.each do |line|
      cols = line.split(',')
      users = users + [parse_user(line)] if cols[0] == 'user'
      sessions = parse_session(sessions, line) if cols[0] == 'session'
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
    report['uniqueBrowsersCount'] = @unique_browsers.count
    report['totalSessions'] = @total_sessions_count
    report['allBrowsers'] =
        @unique_browsers
            .map { |b| b.upcase }
            .sort
            .join(',')

    # Статистика по пользователям
    users_objects = []

    users.each do |user|
      attributes = user
      user_sessions = sessions[user['id']]
      user_object = User.new(attributes: attributes, sessions: user_sessions)
      users_objects = users_objects + [user_object]
    end

    report['usersStats'] = {}

    users_objects.each do |user|
      user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
      report['usersStats'][user_key] ||= {}
      # Собираем количество сессий
      report['usersStats'][user_key]['sessionsCount'] = user.sessions.count
      # Собираем количество времени
      report['usersStats'][user_key]['totalTime'] = user.sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.'
      # Выбираем самую длинную сессию пользователя
      report['usersStats'][user_key]['longestSession'] = user.sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.'
      # Браузеры пользователя через запятую
      report['usersStats'][user_key]['browsers'] = user.sessions.map {|s| s['browser']}.map {|b| b.upcase}.sort.join(', ')
      # Хоть раз использовал IE?
      report['usersStats'][user_key]['usedIE'] = user.sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ }
      # Всегда использовал только Chrome?
      report['usersStats'][user_key]['alwaysUsedChrome'] = user.sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ }
      # Даты сессий через запятую в обратном порядке в формате iso8601
      report['usersStats'][user_key]['dates'] = user.sessions.map{|s| s['date']}.map {|d| Date.parse(d)}.sort.reverse.map { |d| d.iso8601 }
    end

    File.write('result.json', "#{report.to_json}\n")
  end
end
